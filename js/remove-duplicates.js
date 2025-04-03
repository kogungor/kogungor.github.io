// Script to remove duplicate navigation links
document.addEventListener('DOMContentLoaded', function() {
  // Function to remove duplicate links from navigation
  function removeDuplicateLinks() {
    // Get all links in the post-listing area
    const container = document.querySelector('.post-listing');
    if (!container) return;
    
    // Find all direct link children of the post-listing
    const links = container.querySelectorAll('a');
    const seenHrefs = new Set();
    
    // Check each link
    links.forEach(link => {
      const href = link.getAttribute('href');
      
      // Special handling for home links
      if (href === '/' || href === '/index.html' || href === '/home/' || 
          href === '/en/' || href === '/en/index.html' || href === '/en/home/') {
        // If we've seen this type of home link before, hide it
        if (seenHrefs.has('home-link')) {
          link.style.display = 'none';
        } else {
          seenHrefs.add('home-link');
        }
      } else {
        // For other links, check if we've seen this exact href before
        if (seenHrefs.has(href)) {
          link.style.display = 'none';
        } else {
          seenHrefs.add(href);
        }
      }
    });
  }
  
  // Run the function
  removeDuplicateLinks();
});
