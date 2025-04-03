// Script to remove duplicate 'Ana Sayfa' item in the Turkish page
document.addEventListener('DOMContentLoaded', function() {
  // Function to specifically remove duplicate 'Ana Sayfa' in navigation
  function removeDuplicateAnaSayfa() {
    // First, check if we're on a Turkish page
    const htmlLang = document.documentElement.lang;
    if (htmlLang !== 'tr') return;
    
    // Find all navigation items
    const navItems = document.querySelectorAll('.nav-list .nav-item');
    let homeLinks = [];
    
    // Collect all home links
    navItems.forEach(item => {
      const link = item.querySelector('a');
      if (link && (link.textContent.trim() === 'Ana Sayfa' || link.getAttribute('href') === '/')) {
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
      const directLinks = postListing.querySelectorAll(':scope > a');
      let seenLinks = {};
      
      directLinks.forEach(link => {
        const text = link.textContent.trim();
        if (text === 'Ana Sayfa' || link.getAttribute('href') === '/') {
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
  removeDuplicateAnaSayfa();
});
