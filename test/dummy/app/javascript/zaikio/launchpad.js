import Turbolinks from 'turbolinks';
import axios from 'axios';

document.addEventListener('turbolinks:load', function () {
  if (window.zaiLaunchpad) {
    window.zaiLaunchpad.setup({
      loadPersonData: async () => {
        return (await axios.get('/current_person.json')).data;
      },
      // activeOrganizationId: activeOrganizationId, // The currently active organization or null if the user is selected
      activeOrganizationId: null, // The currently active organization or null if the user is selected
      onSelectOrganization: organization => { // if this option is not passed, organization menu will be hidden
        if (organization) {
          // Turbolinks.visit(`/organizations/${organization.slug}`);
        } else {
          // Person was selected
          Turbolinks.visit('/profile');
        }
      }
    });
  }
});
