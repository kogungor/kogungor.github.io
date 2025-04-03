# Multilingual Blog Guide

This guide explains how to manage and create content for your bilingual (Turkish and English) Jekyll blog.

## Structure Overview

Your blog now supports both Turkish (default) and English content with the following structure:

- **Default language**: Turkish (tr)
- **Secondary language**: English (en)
- **Content organization**:
  - Turkish posts: `_posts/` directory
  - English posts: `_posts/en/` directory

## Adding New Content

### Blog Posts

When creating a new blog post in both languages:

1. **Create the Turkish version** in the `_posts/` directory with the filename format: `YYYY-MM-DD-title-in-turkish.md`

2. **Create the English version** in the `_posts/en/` directory with the filename format: `YYYY-MM-DD-title-in-english.md`

3. **Add these front matter variables** to both files:

```yaml
---
layout: post
title: "Your Post Title"
excerpt: "A brief excerpt of your post"
date: YYYY-MM-DD
categories: [category1, category2]
comments: true
lang: tr  # or 'en' for English
ref: unique-reference-id  # Same ID for both versions
translation_url: /YYYY/MM/DD/title-in-other-language/  # URL to the translated version
---
```

Make sure:
- Both versions have the same `ref` value
- Each version points to the other with the correct `translation_url`

### Pages

For static pages:

1. **Create the Turkish version** in the root directory (e.g., `about.html`)
2. **Create the English version** in the `/en/` directory (e.g., `/en/about.html`)
3. **Add these front matter variables**:

```yaml
---
layout: page
title: Page Title
permalink: /page-url/  # or /en/page-url/ for English
lang: tr  # or 'en' for English
ref: page-reference-id  # Same ID for both versions
translation_url: /en/page-url/  # or /page-url/ for English pointing to Turkish
---
```

## Adding New UI Translations

To add new UI element translations:

1. Open `_data/translations.yml`
2. Add your new translation key and values:

```yaml
your_key:
  en: "English text"
  tr: "Turkish text"
```

3. In your templates, use: `{{ site.data.translations.your_key[page.lang] }}`

## Testing Your Changes

After adding new content:

1. Push your changes to GitHub
2. GitHub Pages will automatically build and deploy your site
3. Check both language versions to ensure everything displays correctly
4. Verify that the language switcher works properly between corresponding pages

## SEO Benefits

Your multilingual implementation includes:

- Language-specific metadata in the HTML head
- Proper `hreflang` attributes for search engines
- Language-specific RSS feeds
- Multilingual sitemap
- Consistent URL structure for both languages

This helps search engines understand and properly index your content in both languages.
