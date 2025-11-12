# Open Intranet + Milvus RAG Demo

Integration demo of Open Intranet (Drupal 11) with Milvus Vector Database for RAG (Retrieval-Augmented Generation).

The main Open Intranet repository and project is available at [https://www.drupal.org/project/openintranet](https://www.drupal.org/project/openintranet).

## Prerequisites

Before running the installation script, ensure you have:

1. **Docker Desktop** - Running and active
2. **DDEV** - Installed (`brew install ddev/ddev/ddev` on macOS)
3. **OpenAI API Key** - Required for generating embeddings
   - Get it from: https://platform.openai.com/api-keys
   - Key must start with `sk-proj-` or `sk-`
   - Billing must be enabled (~$0.01-0.10 for the entire demo)

## Installation

```bash
git clone https://github.com/droptica/openintranet_rag_demo.git
cd openintranet_rag_demo
./launch_openintranet_with_rag_demo.sh
```

The script will:
1. Clone Open Intranet from Drupal.org
2. Download Milvus docker-compose configuration
3. Configure DDEV (Drupal 11, PHP 8.3)
4. Start containers (web, db, Milvus)
5. Install Composer dependencies
6. Copy DDEV commands and starter theme
7. Add `drupal/ai_vdb_provider_milvus:^1.1@beta` module
8. Copy `openintranet_milvus_rag` recipe
9. Install Drupal with demo content
10. Apply Milvus RAG recipe configuration
11. **Prompt interactively** for OpenAI API key (validates format)
12. Save API key to Drupal's Key module
13. Index Knowledge Base content to Milvus
14. Generate one-time login URL

During installation, you'll be prompted to paste your OpenAI API key. The script validates the format and stores it securely.

## Structure

```
openintranet_rag_demo/
├── launch_openintranet_with_rag_demo.sh  # Main setup script
├── recipes/
│   └── openintranet_milvus_rag/          # Drupal recipe for Milvus integration
│       ├── recipe.yml
│       ├── composer.json
│       └── config/
│           ├── ai_provider_openai.settings.yml
│           ├── ai_vdb_provider_milvus.settings.yml
│           ├── search_api.server.milvus_embeddings.yml
│           ├── search_api.index.knowledge_base_content.yml
│           ├── ai_search.index.knowledge_base_content.yml
│           ├── key.key.openai_api_key.yml
│           └── views.view.rag_search_example.yml
└── openintranet_source_code/
    └── openintranet/                      # Cloned Open Intranet repository
        ├── composer.json
        ├── ddev_commands/                 # Custom DDEV commands
        ├── recipes/                       # Additional Drupal recipes
        ├── starter-theme/                 # OpenIntranet theme
        └── web/                           # Drupal root
```

## What it installs

- **Open Intranet**: Drupal starter kit for intranet sites
- **Milvus VDB Provider**: `drupal/ai_vdb_provider_milvus:^1.1@beta`
- **Milvus**: Vector database (via docker-compose)
- **RAG Search Example**: Search page at `/search-rag-example` using Milvus embeddings

## Verification

After installation, verify everything is working:

### Check Search Index Status

```bash
cd openintranet_source_code/openintranet
ddev drush search-api:status
```

**Expected output:**
```
knowledge_base_content   Knowledge Base Content   100%         24        24
```

If you see `100%` - everything is working! 🎉

### Verify Milvus Connection

1. Open Milvus Attu UI: Check the port with `ddev describe` (look for Attu service port)
2. Connect to: `http://milvus:19530`
3. Find collection: `openintranet_knowledge_base`
4. Check: Entity Count > 0 ✅

### Test OpenAI API

```bash
cd openintranet_source_code/openintranet
ddev drush php:eval "
\$provider = \Drupal::service('ai.provider')->createInstance('openai');
\$result = \$provider->embeddings('test', 'text-embedding-3-small', []);
echo count(\$result->getNormalized()) . ' dimensions';
"
```

**Expected:** `1536 dimensions`

## Testing RAG Search

The recipe includes a RAG Search Example page at `/search-rag-example`. To test:

1. Access the page: `https://your-site.ddev.site/search-rag-example`
2. Enter a search query (e.g., "milvus configuration")
3. Verify results display with:
   - Title (linked to source page)
   - Content excerpt
   - Relevance score

### Verify View Installation

```bash
cd openintranet_source_code/openintranet
ddev drush views:list | grep rag_search
```

**Expected output:**
```
rag_search_example   RAG Search Example   Page    Enabled
```

## Troubleshooting

### Invalid API key format

**Issue:** Script says "Invalid API key format"

**Solution:**
- Ensure the key starts with `sk-` or `sk-proj-`
- Copy the entire key including the prefix
- Get the key from https://platform.openai.com/api-keys

### Failed to save API key

**Solution:**
```bash
cd openintranet_source_code/openintranet
ddev drush config:set key.key.openai_api_key key_provider_settings.key_value "sk-proj-YOUR_KEY" -y
ddev drush config:set ai_provider_openai.settings api_key openai_api_key -y
ddev drush cache:rebuild
ddev drush search-api:index knowledge_base_content
```

### Entity Count = 0 in Milvus

**Solution:**
```bash
cd openintranet_source_code/openintranet
# Test API key first (should return 1536 dimensions)
ddev drush php:eval "
\$provider = \Drupal::service('ai.provider')->createInstance('openai');
\$result = \$provider->embeddings('test', 'text-embedding-3-small', []);
echo count(\$result->getNormalized()) . ' dimensions';
"

# If API key works, reindex
ddev drush search-api:clear knowledge_base_content
ddev drush search-api:index knowledge_base_content
```

### No search results

**Solution:**
```bash
cd openintranet_source_code/openintranet
# Reindex everything
ddev drush search-api:clear knowledge_base_content
ddev drush search-api:reindex knowledge_base_content
ddev drush search-api:index knowledge_base_content
ddev drush cache:rebuild
```

### Page not found (404) for search page

**Solution:**
```bash
cd openintranet_source_code/openintranet
ddev drush cache:rebuild
ddev drush router:rebuild
```

## Debugging Commands

### View errors
```bash
ddev drush watchdog:show --severity=Error --count=20
```

### Check Milvus connection
```bash
ddev describe
ddev exec curl -I http://milvus:19530
```

### Reindex content
```bash
ddev drush search-api:clear
ddev drush search-api:reindex
ddev drush search-api:index
```

---

## About Droptica

**Built with ❤️  by [Droptica](https://www.droptica.com) 🇵🇱**

Solid Open Source solutions for ambitious companies.

**What we do:**

- **Create:** Open Intranet, Droopler CMS, Druscan
- **AI Development:** AI chatbots (RAG), autonomous agents, OpenAI/Claude integrations, custom AI models, CMS content automation & translation, workflow automation
- **Customize:** Drupal, Mautic, Sylius, Symfony
- **Support & maintain:** Security, updates, training, monitoring 24/7

**Trusted by:** Corporations • SMEs • Startups • Universities • Government

