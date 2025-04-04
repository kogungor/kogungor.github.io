#!/usr/bin/env ruby
# This script adds missing ref and translation_url front matter to posts
# It uses the post's filename and date to generate a unique reference ID
# and creates appropriate translation URLs for each language

require 'yaml'
require 'fileutils'

# Configuration
POSTS_DIR = File.expand_path('../_posts', __dir__)
LANGUAGES = ['en', 'tr']
DEFAULT_LANG = 'tr'

# Create a mapping of posts by date and slug
posts_by_date_slug = {}

# Process all posts
Dir.glob("#{POSTS_DIR}/**/*.md").each do |file|
  # Extract language from directory path
  lang = file.include?('/_posts/en/') ? 'en' : 'tr'
  
  # Read the file content
  content = File.read(file)
  
  # Extract front matter
  if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
    front_matter = YAML.safe_load($1)
    
    # Extract date and slug from filename
    filename = File.basename(file)
    if filename =~ /^(\d{4}-\d{2}-\d{2})-(.+)\.md$/
      date = $1
      slug = $2
      
      # Store post info by date and slug
      posts_by_date_slug[date] ||= {}
      posts_by_date_slug[date][slug] ||= {}
      posts_by_date_slug[date][slug][lang] = {
        file: file,
        front_matter: front_matter,
        permalink: front_matter['permalink']
      }
    end
  end
end

# Update front matter with ref and translation_url
posts_by_date_slug.each do |date, slugs|
  slugs.each do |slug, langs|
    # Generate a reference ID based on date and slug
    ref = "post-#{date}-#{slug}"
    
    # Update front matter for each language version
    langs.each do |lang, post_info|
      file = post_info[:file]
      front_matter = post_info[:front_matter]
      
      # Add ref if missing
      front_matter['ref'] = ref unless front_matter.key?('ref')
      
      # Find translation URLs
      other_langs = LANGUAGES - [lang]
      other_langs.each do |other_lang|
        if langs[other_lang] && langs[other_lang][:permalink]
          front_matter['translation_url'] = langs[other_lang][:permalink]
        end
      end
      
      # Read the full content again
      content = File.read(file)
      
      # Replace front matter
      new_front_matter = front_matter.to_yaml
      new_content = content.sub(/\A---\s*\n.*?\n---\s*\n/m, "---\n#{new_front_matter}---\n\n")
      
      # Write the updated content back to the file
      File.write(file, new_content)
      
      puts "Updated #{file}"
    end
  end
end

puts "Done updating post translations!"
