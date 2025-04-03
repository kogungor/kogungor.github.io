# kogungor.github.io

Personal blog of Kubilay Onur Gungor, focusing on cybersecurity, psychology, mental resilience, and human-centric skills.

## Multilingual Support

This Jekyll site supports both Turkish (default) and English languages. Here's how the multilingual system works:

### Structure

- **Default language**: Turkish (tr)
- **Secondary language**: English (en)
- **Content organization**: 
  - Turkish posts are in the root `_posts/` directory
  - English posts are in `_posts/en/` directory

### Front Matter

Each page and post should include these additional front matter variables for multilingual support:

```yaml
---
lang: tr  # or 'en' for English content
ref: unique-reference-id  # same ID for both language versions of the same content
translation_url: /path/to/other/language/version/  # URL to the translated version
---
```

### Components

1. **Language Switcher**: Located in the sidebar, allows users to switch between languages
2. **Translations**: UI elements are translated using `_data/translations.yml`
3. **Language Configuration**: Language settings are in `_data/languages.yml`

### SEO Optimization

- Language-specific metadata in `<head>`
- Alternate language links for corresponding pages
- Language-specific RSS feeds
- Multilingual sitemap with proper `hreflang` attributes

### Adding New Content

When adding new content in both languages:

1. Create the Turkish version in `_posts/`
2. Create the English version in `_posts/en/`
3. Make sure both have the same `ref` value
4. Add `translation_url` pointing to each other

This implementation is compatible with GitHub Pages as it doesn't rely on unsupported plugins.
