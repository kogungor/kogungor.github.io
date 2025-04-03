// Script to remove duplicate items and tags from navigation
document.addEventListener('DOMContentLoaded', function() {
  // Function to clean up navigation items
  function cleanupNavigation() {
    // Get the language
    const htmlLang = document.documentElement.lang;
    
    // Find all navigation items
    const navItems = document.querySelectorAll('.nav-list .nav-item');
    let homeLinks = [];
    
    // Process each nav item
    navItems.forEach(item => {
      const link = item.querySelector('a');
      if (!link) return;
      
      const text = link.textContent.trim();
      const href = link.getAttribute('href');
      
      // Hide Tags/Etiketler items
      if (text === 'Tags' || text === 'Etiketler' || 
          href.includes('/tags/') || href.includes('/en/tags/')) {
        item.style.display = 'none';
        return;
      }
      
      // Handle duplicate home links in Turkish pages
      if (htmlLang === 'tr' && (text === 'Anasayfa' || href === '/')) {
        homeLinks.push(item);
      }
    });
    
    // If we found more than one home link, remove the duplicates
    if (homeLinks.length > 1) {
      // Keep the first one, remove the rest
      for (let i = 1; i < homeLinks.length; i++) {
        homeLinks[i].style.display = 'none';
      }
    }
    
    // Also check for any duplicate links in the horizontal navigation
    const postListing = document.querySelector('.post-listing');
    if (postListing) {
      const directLinks = postListing.querySelectorAll('a');
      let seenLinks = {};
      
      directLinks.forEach(link => {
        const text = link.textContent.trim();
        const href = link.getAttribute('href');
        
        // Hide Tags/Etiketler items
        if (text === 'Tags' || text === 'Etiketler' || 
            href.includes('/tags/') || href.includes('/en/tags/')) {
          link.style.display = 'none';
          return;
        }
        
        // Handle duplicate home links
        if (htmlLang === 'tr' && (text === 'Anasayfa' || href === '/')) {
          if (seenLinks['home']) {
            link.style.display = 'none';
          } else {
            seenLinks['home'] = true;
          }
        }
      });
    }
  }
  
  // Run the function
  cleanupNavigation();
});
