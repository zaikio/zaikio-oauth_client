// This method is only used
// for flashes that are triggered# through an AJAX request.#flash is an object with key 'notice', 'alert'
// and a message value#

window.showFlash = function(flash) {
  let kind;
  let text;

  if (flash.notice !== undefined) {
    kind = 'notice';
    if (flash.notice === 'success') {
      text = 'Changes saved!';
    } else {
      text = flash.notice;
    }
  } else if (flash.alert !== undefined) {
    kind = 'alert';
    if (flash.alert === 'default') {
      text = 'An error occured. Your changes were not saved!';
    } else {
      text = flash.alert;
    }
  }
  document.querySelector(
    '#flash-container'
  ).innerHTML = `<div class='flash flash--${kind}'>${text}</div>`;
};

window.hideFlash = function() {
  setTimeout(
    () => (document.querySelector('#flash-container').innerHTML = ''),
    3000
  );
};

document.addEventListener('turbolinks:load', function() {
  window.hideFlash();
});
