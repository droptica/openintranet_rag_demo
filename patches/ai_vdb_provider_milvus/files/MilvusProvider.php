<?php

namespace Drupal\ai_vdb_provider_milvus\Plugin\VdbProvider;

use Drupal\Component\Serialization\Json;
use Drupal\Core\Config\ConfigFactoryInterface;
use Drupal\Core\Config\ImmutableConfig;
use Drupal\Core\Entity\EntityFieldManagerInterface;
use Drupal\Core\Form\FormStateInterface;
use Drupal\Core\Messenger\MessengerInterface;
use Drupal\Core\Plugin\ContainerFactoryPluginInterface;
use Drupal\Core\StringTranslation\StringTranslationTrait;
use Drupal\Core\StringTranslation\TranslatableMarkup;
use Drupal\ai\Attribute\AiVdbProvider;
use Drupal\ai\Base\AiVdbProviderClientBase;
use Drupal\ai\Enum\VdbSimilarityMetrics;
use Drupal\ai_vdb_provider_milvus\MilvusV2;
use Drupal\key\KeyRepositoryInterface;
use Drupal\search_api\IndexInterface;
use Drupal\search_api\Query\ConditionGroupInterface;
use Drupal\search_api\Query\QueryInterface;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Symfony\Component\EventDispatcher\EventDispatcherInterface;
use Symfony\Component\HttpFoundation\Request;

/**
 * Plugin implementation of the 'Milvus DB' provider.
 */
#[AiVdbProvider(
  id: 'milvus',
  label: new TranslatableMarkup('Milvus DB'),
)]
class MilvusProvider extends AiVdbProviderClientBase implements ContainerFactoryPluginInterface {

  use StringTranslationTrait;

  /**
   * The API key.
   *
   * @var string
   */
  protected string $apiKey = '';

  /**
   * Constructs an override for the AiVdbClientBase class to add Milvus V2.
   *
   * @param string $pluginId
   *   Plugin ID.
   * @param mixed $pluginDefinition
   *   Plugin definition.
   * @param \Drupal\Core\Config\ConfigFactoryInterface $configFactory
   *   The config factory.
   * @param \Drupal\key\KeyRepositoryInterface $keyRepository
   *   The key repository.
   * @param \Symfony\Component\EventDispatcher\EventDispatcherInterface $eventDispatcher
   *   The event dispatcher.
   * @param \Drupal\Core\Entity\EntityFieldManagerInterface $entityFieldManager
   *   The entity field manager.
   * @param \Drupal\Core\Messenger\MessengerInterface $messenger
   *   The messenger.
   * @param \Drupal\ai_vdb_provider_milvus\MilvusV2 $client
   *   The Milvus V2 API client.
   * @param \Symfony\Component\HttpFoundation\Request $request
   *   The current request.
   */
  public function __construct(
    protected string $pluginId,
    protected mixed $pluginDefinition,
    protected ConfigFactoryInterface $configFactory,
    protected KeyRepositoryInterface $keyRepository,
    protected EventDispatcherInterface $eventDispatcher,
    protected EntityFieldManagerInterface $entityFieldManager,
    protected MessengerInterface $messenger,
    protected MilvusV2 $client,
    protected Request $request,
  ) {
    parent::__construct(
      $this->pluginId,
      $this->pluginDefinition,
      $this->configFactory,
      $this->keyRepository,
      $this->eventDispatcher,
      $this->entityFieldManager,
      $this->messenger,
    );
  }

  /**
   * Load from dependency injection container.
   */
  public static function create(ContainerInterface $container, array $configuration, $plugin_id, $plugin_definition): AiVdbProviderClientBase|static {
    return new static(
      $plugin_id,
      $plugin_definition,
      $container->get('config.factory'),
      $container->get('key.repository'),
      $container->get('event_dispatcher'),
      $container->get('entity_field.manager'),
      $container->get('messenger'),
      $container->get('milvus_v2.api'),
      $container->get('request_stack')->getCurrentRequest(),
    );
  }

  /**
   * {@inheritdoc}
   */
  public function getConfig(): ImmutableConfig {
    return $this->configFactory->get('ai_vdb_provider_milvus.settings');
  }

  /**
   * Set key for authentication of the client.
   *
   * @param mixed $authentication
   *   The authentication.
   */
  public function setAuthentication(mixed $authentication): void {
    $this->apiKey = $authentication;
    $this->client = NULL;
  }

  /**
   * Get v2 client.
   *
   * This is needed for creating collections.
   *
   * @return \Drupal\ai_vdb_provider_milvus\MilvusV2
   *   The Milvus v2 client.
   */
  public function getClient(): MilvusV2 {
    $config = $this->getConnectionData();
    $this->client->setBaseUrl($config['server']);
    $this->client->setPort($config['port']);
    $this->client->setApiKey($config['api_key']);
    return $this->client;
  }

  /**
   * Get connection data.
   *
   * @return array
   *   The connection data.
   */
  public function getConnectionData() {
    $config = $this->getConfig();
    $output['server'] = $this->configuration['server'] ?? $config->get('server');
    // Fail if server is not set.
    if (!$output['server']) {
      throw new \Exception('Milvus server is not configured');
    }
    $token = $config->get('api_key');
    $output['api_key'] = '';
    if ($token) {
      $key = $this->keyRepository->getKey($token);
      if ($key) {
        $output['api_key'] = $key->getKeyValue();
      }
      else {
        throw new \Exception("API key '$token' not found in provider settings.");
      }
    }
    if (!empty($this->configuration['api_key'])) {
      $output['api_key'] = $this->configuration['api_key'];
    }

    $output['port'] = $this->configuration['port'] ?? $config->get('port');
    if (!$output['port']) {
      $output['port'] = (substr($output['server'], 0, 5) === 'https') ? 443 : 80;
    }
    return $output;
  }

  /**
   * {@inheritdoc}
   */
  public function ping(): bool {
    try {
      $return = $this->getClient()->listCollections();
      // Wrong API Key.
      if (isset($return['code']) && $return['code'] === 80001) {
        return FALSE;
      }
      return TRUE;
    }
    catch (\Exception $e) {
      return FALSE;
    }
  }

  /**
   * {@inheritdoc}
   */
  public function isSetup(): bool {
    if ($this->getConfig()->get('server')) {
      return TRUE;
    }
    return FALSE;
  }

  /**
   * {@inheritdoc}
   */
  public function buildSettingsForm(
    array $form,
    FormStateInterface $form_state,
    array $configuration,
  ): array {
    $form = parent::buildSettingsForm($form, $form_state, $configuration);

    // Zilliz serverless does not need a database name.
    if (isset($form['database_name']) && $this->getClient()->isZilliz()) {
      $form['database_name']['#description'] = $this->t('Zilliz Cloud serverless does not need a database name. Set this to anything, like "default". Your database name is automatically determined during indexing and retrieval when Zilliz is used and this field is ignored.');
    }
    return $form;
  }

  /**
   * {@inheritdoc}
   */
  public function validateSettingsForm(array &$form, FormStateInterface $form_state): void {
    parent::validateSettingsForm($form, $form_state);

    $database_settings = $form_state->getValue('database_settings');
    if (empty($database_settings['database_name'])) {
      $form_state->setErrorByName('backend_config][database_name', $this->t('Ensure that your Pinecone API key is correct and that you have created at least one Index in the Pinecone UI.'));
      return;
    }

    $described = $this->getClient()->describeCollection(
      database_name: $database_settings['database_name'],
      collection_name: $database_settings['collection'],
    );
    if (!empty($described['data']) && !empty($described['data']['fields'])) {
      foreach ($described['data']['fields'] as $field) {
        if ($field['type'] !== 'FloatVector') {
          continue;
        }

        if (!isset($field['params'][0]['key']) || $field['params'][0]['key'] !== 'dim') {
          continue;
        }

        $embedding_configuration = $form_state->getValue('embeddings_engine_configuration');
        if ($embedding_configuration['dimensions'] !== (int) $field['params'][0]['value']) {
          $form_state->setErrorByName('embeddings_engine_configuration][dimensions', $this->t('The dimensions found in Milvus/Zilliz are "@dimensions" which does not match the dimensions set here of "@here".', [
            '@dimensions' => (int) $field['params'][0]['value'],
            '@here' => $embedding_configuration['dimensions'],
          ]));
        }
      }
    }

    /** @var \Drupal\Core\Entity\EntityFormInterface */
    $form_object = $form_state->getFormObject();
    // To check if it is a create or edit.
    $entity = $form_object->getEntity();

    // If error code is 100, we can attempt to fix that automatically.
    if (!empty($described['code']) && (int) $described['code'] === 100) {
      $database_settings = $form_state->getValue('database_settings');
      $this->createCollection(
        collection_name: $database_settings['collection'],
        dimension: $form_state->getValue('embeddings_engine_configuration')['dimensions'],
        metric_type: VdbSimilarityMetrics::from($database_settings['metric']),
        database: $database_settings['database_name'],
      );
      $described = $this->getClient()->describeCollection(
        database_name: $database_settings['database_name'],
        collection_name: $database_settings['collection'],
      );
    }

    // Success code is '0'.
    if (
      isset($described['code'])
      && (int) $described['code'] !== 0
      && !empty($described['message'])
      && !$entity->isNew()
    ) {
      $form_state->setErrorByName('backend_config][database_name', $this->t('When validating that the database details for Milvus are correct, the following error code and message were received instead: @code, Message: @message', [
        '@code' => $described['code'],
        '@message' => $described['message'],
      ]));
    }
  }

  /**
   * {@inheritdoc}
   */
  public function viewIndexSettings(array $database_settings): array {
    $results = [];
    $results['ping'] = [
      'label' => $this->t('Ping'),
      'info' => $this->t('Able to reach Milvus/Zilliz via their API.'),
      'status' => $this->ping() ? 'success' : 'error',
    ];

    $results['is_zilliz'] = [
      'label' => $this->t('Is this Milvus or Zilliz?'),
      'info' => $this->getClient()->isZilliz() ? $this->t('Zilliz') : $this->t('Milvus'),
    ];

    $described = $this->getClient()->describeCollection(
      database_name: $database_settings['database_name'],
      collection_name: $database_settings['collection'],
    );
    if (
      isset($described['code'])
      && $described['code'] !== 0
      && $described['code'] !== 200
      && isset($described['message'])
    ) {
      $results['code_message'] = [
        'label' => $this->t('Error'),
        'info' => $this->t('Code: @code, Message: @message', [
          '@code' => $described['code'],
          '@message' => $described['message'],
        ]),
        'status' => 'error',
      ];
      if ((int) $described['code'] === 100) {
        $results['code_message'] = [
          'label' => $this->t('Error advice:'),
          'info' => $this->t('A 100 error code typically means the Collection no longer exists. Resave this Search API Server configuration to attempt to recreate the Collection.'),
          'status' => 'error',
        ];
      }
    }
    if (!empty($described['data'])) {
      if (!empty($described['data']['autoId'])) {
        $results['auto_id'] = [
          'label' => $this->t('Auto ID'),
          'info' => $this->t('Uses Auto ID: @value', [
            '@value' => ($described['data']['autoId'] ? $this->t('True') : $this->t('False')),
          ]),
        ];
      }
      if (!empty($described['data']['partitionsNum'])) {
        $results['partitions'] = [
          'label' => $this->t('Partitions'),
          'info' => $described['data']['partitionsNum'],
        ];
      }
      if (!empty($described['data']['shardsNum'])) {
        $results['shards'] = [
          'label' => $this->t('Shards'),
          'info' => $described['data']['shardsNum'],
        ];
      }
      if (!empty($described['data']['collectionID'])) {
        $results['collection_id'] = [
          'label' => $this->t('Collection ID'),
          'info' => $described['data']['collectionID'],
        ];
      }
      if (!empty($described['data']['collectionName'])) {
        $results['collection_name'] = [
          'label' => $this->t('Collection Name'),
          'info' => $described['data']['collectionName'],
        ];
      }
      if (!empty($described['data']['consistencyLevel'])) {
        $results['consistency_level'] = [
          'label' => $this->t('Consistency Level'),
          'info' => $described['data']['consistencyLevel'],
        ];
      }
      $has_vector_field = FALSE;
      if (!empty($described['data']['fields'])) {
        foreach ($described['data']['fields'] as $key => $field) {
          $results['field_' . $key] = [
            'label' => $this->t('Field "@name"', [
              '@name' => $field['name'],
            ]),
            'info' => $field['type'] . (!empty($field['params']) ? Json::encode($field['params']) : ''),
          ];
          if ($field['name'] === 'vector' && $field['type'] === 'FloatVector') {
            $has_vector_field = TRUE;
          }
        }
      }
      if (!$has_vector_field) {
        $results['missing_vector_field'] = [
          'label' => $this->t('Missing Vector Field'),
          'info' => $this->t('There must be a field with index name "vector" and field type "FloatVector". This can be checked in the Milvus UI on the Collection Overview page.'),
          'status' => 'error',
        ];
      }

      if (!empty($described['data']['indexes'])) {
        foreach ($described['data']['indexes'] as $key => $index) {
          $results['index_' . $key] = [
            'label' => $this->t('Index "@number" field name "@fieldName" metric type:', [
              '@number' => $key,
              '@fieldName' => $index['fieldName'],
            ]),
            'info' => $index['metricType'],
          ];
        }
      }
    }

    if (getenv('IS_DDEV_PROJECT') == 'true' && !$this->getClient()->isZilliz()) {
      $results['ddev_ui'] = [
        'label' => $this->t('Milvus DDEV UI'),
        'info' => $this->t('<a href="@milvus" target="_blank">Milvus DDEV UI</a>', [
          '@milvus' => 'https://' . $this->request->getHost() . ':8521',
        ]),
      ];
    }

    return $results;
  }

  /**
   * {@inheritdoc}
   */
  public function getCollections(string $database = 'default'): array {
    return $this->getClient()->listCollections($database);
  }

  /**
   * {@inheritdoc}
   */
  public function createCollection(
    string $collection_name,
    int $dimension,
    VdbSimilarityMetrics $metric_type = VdbSimilarityMetrics::CosineSimilarity,
    string $database = 'default',
  ): void {
    $metric_name = match ($metric_type) {
      VdbSimilarityMetrics::EuclideanDistance => 'L2',
      VdbSimilarityMetrics::CosineSimilarity => 'COSINE',
      VdbSimilarityMetrics::InnerProduct => 'IP',
    };
    $client = $this->getClient();
    $client->createCollection(
      $collection_name,
      $database,
      $dimension,
      $metric_name,
    );
  }

  /**
   * {@inheritdoc}
   */
  public function dropCollection(
    string $collection_name,
    string $database = 'default',
  ): void {
    $this->getClient()->dropCollection($collection_name);
  }

  /**
   * {@inheritdoc}
   *
   * @throws \Exception
   */
  public function insertIntoCollection(
    string $collection_name,
    array $data,
    string $database = 'default',
  ): void {
    $processed = FALSE;
    while (!$processed) {
      $response = $this->getClient()->insertIntoCollection(
        $collection_name,
        $data,
        $database,
      );

      if (!isset($response['code'])) {
        throw new \Exception("Failed to record vector.");
      }

      switch ($response['code']) {
        case 1100:
          $this->sanitizeMaxLength($data);
          break;

        case 200:
        case 0:
          $processed = TRUE;
          break;

        default:
          throw new \Exception("Failed to insert into collection: " . $response['message']);
      }
    }
  }

  /**
   * {@inheritdoc}
   */
  public function deleteFromCollection(
    string $collection_name,
    array $ids,
    string $database = 'default',
  ): void {
    $this->getClient()->deleteFromCollection($collection_name, $ids, $database);
  }

  /**
   * {@inheritdoc}
   */
  /**
   * {@inheritdoc}
   */
  public function prepareFilters(QueryInterface $query): string {
    $index = $query->getIndex();
    $condition_group = $query->getConditionGroup();
    return $this->processConditionGroup($index, $condition_group);
  }

  /**
   * Processes a condition group, including handling nested condition groups.
   *
   * @param \Drupal\search_api\IndexInterface $index
   *   The Search API Index.
   * @param \Drupal\search_api\Query\ConditionGroupInterface $condition_group
   *   The condition group.
   *
   * @return string
   *   The filter expression string for Milvus.
   */
  protected function processConditionGroup(IndexInterface $index, ConditionGroupInterface $condition_group): string {
    $filters = [];
    $conjunction = $condition_group->getConjunction();
    // Use OR (||) or AND (&&) based on the condition group's conjunction.
    $conjunctionOperator = ($conjunction === 'OR') ? ' || ' : ' && ';

    foreach ($condition_group->getConditions() as $condition) {

      // Check if the current condition is actually a nested ConditionGroup.
      if ($condition instanceof ConditionGroupInterface) {
        // Recursively process the nested ConditionGroup and wrap in parentheses.
        $nested_filter = $this->processConditionGroup($index, $condition);
        if ($nested_filter) {
          $filters[] = '(' . $nested_filter . ')';
        }
        continue;
      }

      $fieldData = $index->getField($condition->getField());

      // 'Special Fields' created by Search API are not actually fields and
      // cannot be applied as Milvus conditions.
      // @see _search_api_views_data_special_fields().
      if (!$fieldData) {
        continue;
      }

      // Get the field type or its intrinsic field, like drupal_entity_id.
      $fieldType = $fieldData ? $fieldData->getType() : 'string';
      $isMultiple = $fieldData ? $this->isMultiple($fieldData) : FALSE;
      $values = is_array($condition->getValue()) ? $condition->getValue() : [$condition->getValue()];
      if (in_array($fieldType, ['string', 'full_text'])) {
        $normalizedValues = '"' . implode('","', $values) . '"';
      }
      else {
        $normalizedValues = implode(',', $values);
      }
      if ($isMultiple) {
        $comparisonOperator = $condition->getOperator();
        if ($comparisonOperator === '=' && count($values) === 1) {
          // For equality check with a single value on a list field,
          // check if the array contains that value.
          $filters[] = 'array_contains(' . $fieldData->getFieldIdentifier() . ', ' . $normalizedValues . ')';
        }
        elseif ($comparisonOperator === 'IN' || ($comparisonOperator === '=' && count($values) > 1)) {
          // For IN operator or multiple values, check if any values match.
          $filters[] = 'JSON_CONTAINS_ANY(' . $fieldData->getFieldIdentifier() . ', [' . $normalizedValues . '])';
        }
        else {
          $this->messenger->addWarning('The vector database @name does not support negative operator on multiple fields.', [
            '@name' => $this->getClient()->getPluginId(),
          ]);
        }
      }
      else {
        $comparisonOperator = $condition->getOperator();
        if ($comparisonOperator === '=') {
          $comparisonOperator = '==';
        }
        $filters[] = '(' . $fieldData->getFieldIdentifier() . ' ' . $comparisonOperator . ' ' . $normalizedValues . ')';
      }
    }

    if ($filters) {
      return implode($conjunctionOperator, $filters);
    }
    return '';
  }

  /**
   * {@inheritdoc}
   */
  public function querySearch(
    string $collection_name,
    array $output_fields,
    mixed $filters = 'id not in [0]',
    int $limit = 10,
    int $offset = 0,
    string $database = 'default',
  ): array {
    $data = $this->getClient()->query(
      $collection_name,
      $output_fields,
      $filters,
      $limit,
      $offset,
      $database
    );
    return $data['data'] ?? [];
  }

  /**
   * {@inheritdoc}
   */
  public function vectorSearch(
    string $collection_name,
    array $vector_input,
    array $output_fields,
    QueryInterface $query,
    mixed $filters = '',
    int $limit = 10,
    int $offset = 0,
    string $database = 'default',
  ): array {
    $data = $this->getClient()->search(
      $collection_name,
      $vector_input,
      $output_fields,
      $filters,
      $limit,
      $offset,
      $database
    );
    return $data['data'] ?? [];
  }

  /**
   * {@inheritdoc}
   */
  public function getVdbIds(
    string $collection_name,
    array $drupalIds,
    string $database = 'default',
  ): array {
    $data = $this->querySearch(
      collection_name: $collection_name,
      output_fields: ['id'],
      filters: "drupal_entity_id in [\"" . implode('","', $drupalIds) . "\"]",
      database: $database,
      limit: 16384,
    );
    $ids = [];
    if (!empty($data)) {
      foreach ($data as $item) {
        $ids[] = $item['id'];
      }
    }
    return $ids;
  }

  /**
   * Trim the data.
   *
   * @throws \Exception
   */
  private function sanitizeMaxLength(&$data): void {

    // Nothing to do, if we do not have content field or it is empty.
    if (!isset($data['content']) || (strlen($data['content']) == 0)) {
      throw new \Exception("Failed to record vector.");
    }

    $total_length = $this->countLength($data);

    // If the content is too long, shorten the content by a calculated value.
    if ($total_length > 65536) {
      $difference = 65536 - $total_length;
    }
    // If the calculated content is shorter, but API still reports the issue
    // shorten the content by additional 5%.
    else {
      $difference = -max(1, (int) (mb_strlen($data['content'], 'UTF-8') * 0.05));
    }
    $data['content'] = mb_substr($data['content'], 0, $difference, 'UTF-8');
  }

  /**
   * Calculate size of data.
   *
   * @param array $data
   *   Data in saved fields.
   *
   * @return int
   *   Number of UTF-8 characters in the data.
   */
  private function countLength(array $data): int {
    $total_length = 0;
    foreach ($data as $key => $value) {
      if ($key !== 'vector') {
        $total_length += mb_strlen((string) $value, 'UTF-8') + mb_strlen($key, 'UTF-8') + 22;
      }
      else {
        $total_length += count($value) + 28;
      }
    }
    return $total_length;
  }

}

