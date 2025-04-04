#!/bin/bash

# Update Turkish posts
for file in _posts/tr/*.md; do
  # Check if permalink already exists
  if ! grep -q "permalink:" "$file"; then
    # Extract date and title from filename
    filename=$(basename "$file")
    year=$(echo "$filename" | cut -d'-' -f1)
    month=$(echo "$filename" | cut -d'-' -f2)
    
    # Add permalink after lang: tr line
    sed -i '' '/lang: tr/a\
permalink: /tr/articles/'"$year"'-'"$month"'/'"${filename%.md}"'/' "$file"
  fi
done

# Update English posts
for file in _posts/en/*.md; do
  # Check if permalink already exists
  if ! grep -q "permalink:" "$file"; then
    # Extract date and title from filename
    filename=$(basename "$file")
    year=$(echo "$filename" | cut -d'-' -f1)
    month=$(echo "$filename" | cut -d'-' -f2)
    
    # Add permalink after lang: en line
    sed -i '' '/lang: en/a\
permalink: /en/articles/'"$year"'-'"$month"'/'"${filename%.md}"'/' "$file"
  fi
done

echo "Permalinks updated successfully!"
