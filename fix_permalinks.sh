#!/bin/bash

# Function to convert title to slug
slugify() {
  echo "$1" | iconv -t ascii//TRANSLIT | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]'
}

# Update Turkish posts
for file in _posts/tr/*.md; do
  echo "Processing $file"
  
  # Get the title from front matter
  title=$(grep "^title:" "$file" | sed 's/^title: //' | sed 's/^title:  *//' | sed 's/"//g')
  
  # If no title found, use filename
  if [ -z "$title" ]; then
    filename=$(basename "$file" .md)
    # Remove date part from filename (YYYY-MM-DD-)
    title=${filename:11}
  fi
  
  # Create slug from title
  slug=$(slugify "$title")
  
  # Extract date from filename
  filename=$(basename "$file")
  year=$(echo "$filename" | cut -d'-' -f1)
  month=$(echo "$filename" | cut -d'-' -f2)
  
  # Create new permalink
  new_permalink="/tr/articles/$year-$month/$slug/"
  
  # Check if permalink already exists and replace it, or add it after lang: tr
  if grep -q "^permalink:" "$file"; then
    sed -i '' "s|^permalink:.*|permalink: $new_permalink|" "$file"
  else
    sed -i '' "/lang: tr/a\\
permalink: $new_permalink" "$file"
  fi
done

# Update English posts
for file in _posts/en/*.md; do
  echo "Processing $file"
  
  # Get the title from front matter
  title=$(grep "^title:" "$file" | sed 's/^title: //' | sed 's/^title:  *//' | sed 's/"//g')
  
  # If no title found, use filename
  if [ -z "$title" ]; then
    filename=$(basename "$file" .md)
    # Remove date part from filename (YYYY-MM-DD-)
    title=${filename:11}
  fi
  
  # Create slug from title
  slug=$(slugify "$title")
  
  # Extract date from filename
  filename=$(basename "$file")
  year=$(echo "$filename" | cut -d'-' -f1)
  month=$(echo "$filename" | cut -d'-' -f2)
  
  # Create new permalink
  new_permalink="/en/articles/$year-$month/$slug/"
  
  # Check if permalink already exists and replace it, or add it after lang: en
  if grep -q "^permalink:" "$file"; then
    sed -i '' "s|^permalink:.*|permalink: $new_permalink|" "$file"
  else
    sed -i '' "/lang: en/a\\
permalink: $new_permalink" "$file"
  fi
done

echo "Permalinks updated successfully!"
