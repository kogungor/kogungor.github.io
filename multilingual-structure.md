# Multilingual Structure Documentation

This document outlines the standardized multilingual structure implemented for this blog.

## Directory Structure

The blog now follows a consistent directory structure for all languages:

```
/
├── _config.yml                # Main configuration file
├── _data/                     # Data files
│   ├── languages.yml          # Language definitions
│   └── translations.yml       # UI translations
├── _includes/                 # Template includes
│   ├── language-switcher.html # Language switcher component
│   ├── en/                    # English-specific includes
│   └── tr/                    # Turkish-specific includes
├── _layouts/                  # Layout templates
├── _posts/                    # Blog posts
│   ├── en/                    # English posts
│   └── tr/                    # Turkish posts
├── en/                        # English content
│   ├── about/                 # About page
│   ├── archive.html           # Archive page
│   ├── index.html             # Home page
│   └── tags.html              # Tags page
├── tr/                        # Turkish content
│   ├── about/                 # About page
│   ├── archive.html           # Archive page
│   ├── index.html             # Home page
│   └── tags.html              # Tags page
└── index.html                 # Root redirect (language detection)
```

## How It Works

1. **Language Detection**:
   - The root `index.html` detects the user's browser language and redirects to the appropriate language version.
   - If the browser language is not supported, it redirects to the default language (Turkish).

2. **Language Directories**:
   - Each language has its own dedicated directory (`/en/`, `/tr/`).
   - This makes it easy to add new languages in the future.

3. **Language Switcher**:
   - The language switcher in the sidebar allows users to switch between languages.
   - It automatically maps URLs between language versions.

4. **Content Organization**:
   - Blog posts are organized in language-specific directories (`_posts/en/`, `_posts/tr/`).
   - Each post has `lang`, `ref`, and `translation_url` front matter variables to link corresponding content across languages.

5. **Configuration**:
   - Language settings are defined in `_config.yml`.
   - Language-specific data is stored in `_data/languages.yml` and `_data/translations.yml`.

## Adding a New Language

To add a new language (e.g., German):

1. **Update Configuration Files**:
   ```yaml
   # _config.yml
   languages: [tr, en, de]
   language_dirs:
     tr: "/tr"
     en: "/en"
     de: "/de"
   titles:
     tr: "Saatin Tersi Yonunde Simya"
     en: "Alchemy Against the Clock"
     de: "Alchemie gegen die Uhr"
   descriptions:
     tr: "..."
     en: "..."
     de: "..."
   ```

2. **Add Language Definition**:
   ```yaml
   # _data/languages.yml
   de:
     label: Deutsch
     icon: 🇩🇪
     root: /de
   ```

3. **Add Translations**:
   ```yaml
   # _data/translations.yml
   tag_cloud:
     tr: "Etiket Bulutu"
     en: "Tag Cloud"
     de: "Tag-Wolke"
   # Add other UI elements...
   ```

4. **Create Language Directory Structure**:
   ```
   mkdir -p de/about de/tags
   ```

5. **Create Basic Pages**:
   - Create `de/index.html`, `de/about/index.html`, `de/archive.html`, and `de/tags.html`.
   - Set appropriate front matter with `lang: de` and `translation_url` pointing to corresponding pages in other languages.

6. **Add Content**:
   - Create a directory for German posts: `_posts/de/`.
   - Add translated content with appropriate front matter.

## Best Practices

1. **Consistent Front Matter**:
   - Always include `lang`, `ref`, and `translation_url` in front matter.
   - Use consistent `ref` values across language versions of the same content.

2. **URL Structure**:
   - Follow the pattern `/{language}/path/to/content/` for all URLs.
   - This ensures consistent URL structure across languages.

3. **Translation Management**:
   - Keep UI translations in `_data/translations.yml`.
   - Organize by concept rather than language for easier maintenance.
