# Multilingual Improvements Roadmap

This document outlines the plan for improving the multilingual structure of the Jekyll blog to make it more modular and easier to add new languages in the future.

## Current Status Analysis

### Strengths
1. **Language Configuration** ✅
   - `_data/languages.yml` uses a clean key-value structure
   - Each language has its own configuration block with label, icon, and root path

2. **Translations System** ✅
   - `_data/translations.yml` organizes UI text by concept first, then by language
   - Adding a new language only requires adding new entries to existing keys

3. **Include Files Structure** ✅
   - Organized as `_includes/[language]/sections/`
   - Clear separation of language-specific content

4. **Content Organization** ⚠️
   - Posts: `_posts/en/` for English content
   - Pages: `/en/` directory for English pages
   - Turkish pages are in the root directory (not in `/tr/`)

5. **Language Switcher** ❌
   - Current implementation has hardcoded logic for English and Turkish
   - Uses specific language codes in conditionals
   - URL manipulation is specific to the current two-language setup

## Improvement Plan

### 1. Generalize the Language Switcher
- **Priority**: High
- **Dependencies**: None
- **Description**: Rewrite the language switcher to handle any number of languages dynamically without hardcoded language-specific logic.
- **Files to modify**:
  - `_includes/language-switcher.html`

### 2. Standardize URL Structure
- **Priority**: Medium
- **Dependencies**: Generalized language switcher
- **Description**: Consider moving Turkish content to `/tr/` to match the pattern used for English, creating a consistent pattern: `/{language-code}/` for all languages.
- **Files to modify**:
  - `_config.yml` (possibly)
  - `_data/languages.yml`
  - Front matter in content files

### 3. Complete Directory Structure Reorganization
- **Priority**: Medium
- **Dependencies**: Standardized URL structure
- **Description**: Apply the language-based organization to other parts of the site, ensuring all content types follow the same pattern.
- **Directories to reorganize**:
  - Consider moving Turkish posts to `_posts/tr/`
  - Other content directories as needed

### 4. Create Language Configuration Guide
- **Priority**: Low
- **Dependencies**: All other improvements
- **Description**: Document the steps needed to add a new language, including templates for required files and front matter.
- **Files to create**:
  - `docs/adding-new-language.md`

## Implementation Steps

For each new language to be added in the future:
1. Add the language to `_data/languages.yml`
2. Add translations to `_data/translations.yml`
3. Create language-specific directories following the established pattern
4. Add content with proper front matter

## Notes
- All changes must be compatible with GitHub Pages
- Maintain backward compatibility where possible
- Test thoroughly after each major change
