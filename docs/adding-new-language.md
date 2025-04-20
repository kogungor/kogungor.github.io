# Adding a New Language to Your Jekyll Blog

This guide outlines the steps needed to add a new language to your multilingual Jekyll blog.

## Step 1: Configure the Language

Add the new language to `_data/languages.yml`:

```yaml
# Example for adding German
de:
  label: Deutsch
  icon: 🇩🇪
  root: /de
```

## Step 2: Add UI Translations

Add translations for all UI elements in `_data/translations.yml`:

```yaml
home:
  en: "Home"
  tr: "Anasayfa"
  de: "Startseite"
# Continue for all other UI elements
```

## Step 3: Create Language-Specific Directories

Create the following directories for your new language:

```
_includes/[language-code]/sections/
_posts/[language-code]/
/[language-code]/
/[language-code]/about/
/[language-code]/categories/
# Add other necessary directories
```

## Step 4: Create Section Files

Create language-specific section files in `_includes/[language-code]/sections/`:

- `about.html`
- `career.html`
- `education.html`
- `skills.html`
- Any other section files needed

## Step 5: Create Page Templates

Create language-specific pages in `/[language-code]/`:

1. Create an `index.html` file with proper front matter:
   ```yaml
   ---
   layout: post_listing
   title: Home
   permalink: /[language-code]/
   lang: [language-code]
   ref: home
   translation_url: /
   ---
   ```

2. Create an about page in `/[language-code]/about/index.html` with proper front matter:
   ```yaml
   ---
   layout: page
   title: About
   permalink: /[language-code]/about/
   lang: [language-code]
   ref: about
   translation_url: /about/
   ---
   ```

3. Create other necessary pages following the same pattern

## Step 6: Add Content

Add blog posts in `_posts/[language-code]/` with proper front matter:

```yaml
---
layout: post
title: "Your Post Title"
date: YYYY-MM-DD HH:MM:SS
categories: [Your Categories]
comments: true
lang: [language-code]
ref: unique-reference-id
translation_url: /path/to/translation
---
```

## Front Matter Requirements

All multilingual content must include these front matter variables:

- `lang`: The language code (e.g., 'en', 'tr', 'de')
- `ref`: A unique identifier shared across translations of the same content
- `translation_url`: The URL to the translation in another language (if available)

## Testing

After adding a new language:

1. Build your site locally: `bundle exec jekyll serve`
2. Test the language switcher functionality
3. Verify that all pages display correctly in the new language
4. Check that links between translated content work properly
