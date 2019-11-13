import { ajax, delegate } from '@rails/ujs';

window.showModal = function(html) {
  document.querySelector('body').classList.add('with-modal');
  document.querySelector('#modal__content').innerHTML = html;
  // Set manual focus, because modal might be cached
  if (document.querySelector('#modal__content input[autofocus]') !== null) {
    document.querySelector('#modal__content input[autofocus]').focus();
  }
};

window.hideModal = function() {
  document.querySelector('body').classList.remove('with-modal');
  document.querySelector('#modal__content').innerHTML = '';
};

delegate(document, 'span[url]', 'click', event => {
  const element = event.target.closest('span[url]');
  const url = element.getAttribute('url');
  ajax({
    type: 'GET',
    url,
    dataType: 'script',
  });
});
