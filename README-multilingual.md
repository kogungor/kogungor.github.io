# Multilingual Blog Structure

This README explains the standardized multilingual structure implemented for this blog.

## Overview

The blog now follows a consistent directory structure for all languages, making it easier to:
- Add new languages in the future
- Maintain consistent navigation across languages
- Ensure proper SEO for multilingual content

## Directory Structure

```
/
├── _config.yml                # Main configuration file with language settings
├── _data/                     # Data files
│   ├── languages.yml          # Language definitions
│   └── translations.yml       # UI translations
├── _includes/                 # Template includes
│   ├── language-switcher.html # Language switcher component
│   ├── en/                    # English-specific includes
│   └── tr/                    # Turkish-specific includes
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

## Key Components

### 1. Language Configuration

Languages are defined in `_config.yml`:

```yaml
default_lang: tr
languages: [tr, en]
language_dirs:
  tr: "/tr"
  en: "/en"
titles:
  tr: "Saatin Tersi Yonunde Simya"
  en: "Alchemy Against the Clock"
```

### 2. Language Definitions

Language-specific information is stored in `_data/languages.yml`:

```yaml
en:
  label: English
  icon: 🇺🇸
  root: /en
tr:
  label: Türkçe
  icon: 🇹🇷
  root: /tr
```

### 3. UI Translations

UI text is stored in `_data/translations.yml`:

```yaml
tag_cloud:
  tr: "Etiket Bulutu"
  en: "Tag Cloud"
```

### 4. Language Switcher

The language switcher component in `_includes/language-switcher.html` handles language switching:

```html
<div class="language-switcher">
  {% for language in site.data.languages %}
    {% assign lang_code = language[0] %}
    {% assign lang_data = language[1] %}
    
    {% if lang_code == page.lang %}
      <span class="active-language">{{ lang_data.icon }} {{ lang_data.label }}</span>
    {% else %}
      <!-- Language switching logic -->
    {% endif %}
  {% endfor %}
</div>
```

### 5. Front Matter for Multilingual Content

Each page and post includes language-specific front matter:

```yaml
---
layout: post
title: "Post Title"
lang: en                      # Language code
ref: unique-reference-id      # Shared ID across translations
translation_url: /tr/path/    # URL to translation
---
```

## Adding a New Language

To add a new language (e.g., German):

1. Update `_config.yml`:
   ```yaml
   languages: [tr, en, de]
   language_dirs:
     tr: "/tr"
     en: "/en"
     de: "/de"
   titles:
     tr: "Saatin Tersi Yonunde Simya"
     en: "Alchemy Against the Clock"
     de: "Alchemie gegen die Uhr"
   ```

2. Add to `_data/languages.yml`:
   ```yaml
   de:
     label: Deutsch
     icon: 🇩🇪
     root: /de
   ```

3. Add translations to `_data/translations.yml`

4. Create directory structure:
   ```
   mkdir -p de/about de/tags _posts/de
   ```

5. Create basic pages (index.html, about.html, etc.) with appropriate front matter

6. Add translated content

## Best Practices

1. **Consistent Front Matter**: Always include `lang`, `ref`, and `translation_url`
2. **URL Structure**: Follow the pattern `/{language}/path/to/content/`
3. **Translation Management**: Keep UI translations in `_data/translations.yml`
4. **Testing**: Test language switching on all pages when adding new content
