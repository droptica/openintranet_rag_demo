<?php

namespace Drupal\ai_vdb_provider_milvus;

use Drupal\Component\Serialization\Json;
use GuzzleHttp\Client;

/**
 * Extends Milvus with extra calls.
 */
class MilvusV2 {

  /**
   * The http client.
   *
   * @var \GuzzleHttp\Client
   */
  protected Client $client;

  /**
   * API Token.
   *
   * @var string
   */
  private string $apiKey;

  /**
   * The base URL.
   *
   * @var string
   */
  private string $baseUrl;

  /**
   * The port.
   *
   * @var int
   */
  private int $port = 443;

  /**
   * Constructor.
   *
   * @param \GuzzleHttp\Client $client
   *   The http client.
   */
  public function __construct(Client $client) {
    $this->client = $client;
  }

  /**
   * Set the API key.
   *
   * @param string $apiKey
   *   The API key.
   */
  public function setApiKey(string $apiKey) {
    $this->apiKey = $apiKey;
  }

  /**
   * Set the base URL.
   *
   * @param string $baseUrl
   *   The base URL.
   */
  public function setBaseUrl(string $baseUrl) {
    $this->baseUrl = $baseUrl;
  }

  /**
   * Set the port.
   *
   * @param int $port
   *   The port.
   */
  public function setPort(int $port) {
    $this->port = $port;
  }

  /**
   * Create collection.
   *
   * @param string $collection_name
   *   The collection.
   * @param string $database_name
   *   The database.
   * @param int $dimension
   *   The dimension.
   * @param string $metric_type
   *   The metric type.
   * @param array $options
   *   Extra options.
   */
  public function createCollection(string $collection_name, string $database_name, int $dimension, string $metric_type, array $options = []) {
    $options['collectionName'] = $collection_name;
    $options['dimension'] = $dimension;
    $options['metricType'] = $metric_type;
    if (!$this->isZilliz()) {
      $options['dbName'] = $database_name;
    }
    $options['autoID'] = $options['autoID'] ?? TRUE;
    $options['schema']['autoID'] = TRUE;
    // Enable dynamic fields to store additional metadata like access control
    // fields (role_access, node_grants), content, and drupal_entity_id.
    $options['schema']['enableDynamicField'] = TRUE;

    return Json::decode($this->makeRequest('vectordb/collections/create', [], 'POST', $options));
  }

  /**
   * Drop collection.
   *
   * @param string $collection_name
   *   The collection.
   * @param string $database_name
   *   The database.
   *
   * @return array
   *   The response.
   */
  public function dropCollection(string $collection_name, string $database_name = ''): array {
    $params = [
      'collectionName' => $collection_name,
    ];
    if ($database_name && !$this->isZilliz()) {
      $params['dbName'] = $database_name;
    }
    return Json::decode($this->makeRequest('vectordb/collections/drop', [], 'POST', $params));
  }

  /**
   * List collections.
   *
   * @param string $database_name
   *   The database.
   *
   * @return array
   *   The collections.
   */
  public function listCollections(string $database_name = ''): array {
    // Has to be an object, when empty ¯\_(ツ)_/¯.
    $data = $database_name && !$this->isZilliz() ? ['dbName' => $database_name] : new \stdClass();
    return Json::decode($this->makeRequest('vectordb/collections/list', [], 'POST', $data));
  }

  /**
   * Describe collection.
   *
   * @param string $database_name
   *   The database.
   * @param string $collection_name
   *   The collection name.
   *
   * @return array
   *   The collections.
   */
  public function describeCollection(
    string $database_name = '',
    string $collection_name = '',
  ): array {
    $data = [
      'collectionName' => $collection_name,
    ];
    if ($database_name && !$this->isZilliz()) {
      $data['dbName'] = $database_name;
    }
    return Json::decode($this->makeRequest('vectordb/collections/describe', [], 'POST', $data));
  }

  /**
   * Insert into the collection.
   *
   * @param string $collection_name
   *   The collection.
   * @param array $data
   *   The data.
   * @param string $database_name
   *   The database.
   *
   * @return array
   *   The response.
   */
  public function insertIntoCollection(string $collection_name, array $data, string $database_name = ''): array {
    $params = [
      'collectionName' => $collection_name,
      'data' => [$data],
    ];
    if ($database_name && !$this->isZilliz()) {
      $params['dbName'] = $database_name;
    }
    return Json::decode($this->makeRequest('vectordb/entities/insert', [], 'POST', $params));
  }

  /**
   * Delete from the collection.
   *
   * @param string $collection_name
   *   The collection.
   * @param array $ids
   *   The ids.
   * @param string $database_name
   *   The database name.
   *
   * @return array
   *   The response.
   */
  public function deleteFromCollection(string $collection_name, array $ids, string $database_name = 'default'): array {
    $params = [
      'collectionName' => $collection_name,
      'filter' => 'id in [' . implode(',', $ids) . ']',
    ];
    if ($database_name && !$this->isZilliz()) {
      $params['dbName'] = $database_name;
    }
    return Json::decode($this->makeRequest('vectordb/entities/delete', [], 'POST', $params));
  }

  /**
   * Query collection.
   *
   * @param string $collection_name
   *   The collection.
   * @param array $output_fields
   *   The output fields.
   * @param string $filters
   *   The filters.
   * @param int $limit
   *   The limit.
   * @param int $offset
   *   The offset.
   * @param string $database_name
   *   The database.
   *
   * @return array
   *   The response.
   */
  public function query(string $collection_name, array $output_fields, string $filters = 'id not in [0]', int $limit = 10, int $offset = 0, string $database_name = ''): array {
    $params = [
      'collectionName' => $collection_name,
      'filter' => $filters,
      'outputFields' => $output_fields,
      'limit' => $limit,
      'offset' => $offset,
    ];
    // Only when its Zilliz.
    if ($database_name && !$this->isZilliz()) {
      $params['dbName'] = $database_name;
    }

    $response = $this->makeRequest('vectordb/entities/query', [], 'POST', $params);
    return Json::decode($response);
  }

  /**
   * Search.
   *
   * @param string $collection_name
   *   The collection.
   * @param array $vector_input
   *   The vector input.
   * @param array $output_fields
   *   The output fields.
   * @param string $filters
   *   The filters.
   * @param int $limit
   *   The limit.
   * @param int $offset
   *   The offset.
   * @param string $database_name
   *   The database.
   */
  public function search(string $collection_name, array $vector_input, array $output_fields, string $filters = '', int $limit = 10, int $offset = 0, string $database_name = '') {
    $params = [
      'collectionName' => $collection_name,
      'data' => [$vector_input],
      'annsField' => 'vector',
      'outputFields' => $output_fields,
      'limit' => $limit,
      'offset' => $offset,
    ];

    if ($database_name && !$this->isZilliz()) {
      $params['dbName'] = $database_name;
    }

    if ($filters !== '') {
      $params['filter'] = $filters;
    }

    $response = $this->makeRequest('vectordb/entities/search', [], 'POST', $params);
    return Json::decode($response);
  }

  /**
   * Make Milvus call.
   *
   * @param string $path
   *   The path.
   * @param array $query_string
   *   The query string.
   * @param string $method
   *   The method.
   * @param string $body
   *   Data to attach if POST/PUT/PATCH.
   * @param array $options
   *   Extra headers.
   *
   * @return string|object
   *   The return response.
   */
  protected function makeRequest($path, array $query_string = [], $method = 'GET', $body = '', array $options = []) {
    if (!$this->baseUrl) {
      throw new \Exception('No base url set.');
    }
    // Don't wait to long.
    $options['connect_timeout'] = 120;
    $options['read_timeout'] = 120;
    $options['timeout'] = 120;

    // JSON unless its multipart.
    if (empty($options['multipart'])) {
      $options['headers']['Content-Type'] = 'application/json';
      $options['headers']['accept'] = 'application/json';
    }

    // Credentials.
    if ($this->apiKey) {
      $options['headers']['authorization'] = 'Bearer ' . $this->apiKey;
    }

    if ($body) {
      $options['body'] = json_encode($body);
    }

    $url = $this->baseUrl . ':' . $this->port;

    $new_url = rtrim($url, '/') . '/v2/' . $path;
    $new_url .= count($query_string) ? '?' . http_build_query($query_string) : '';

    $res = $this->client->request($method, $new_url, $options);

    return $res->getBody();
  }

  /**
   * Check if we are running on zilliz.
   *
   * @return bool
   *   If we are running on zilliz.
   */
  public function isZilliz(): bool {
    // The base url could either contain zillizcloud.com or cloud.zilliz.com.
    return preg_match('(zillizcloud.com|cloud.zilliz.com)', $this->baseUrl) === 1;
  }

}
