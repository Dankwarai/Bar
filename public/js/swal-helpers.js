// Lightweight native replacements — no SweetAlert2 dependency.

function swalConfirm(title, text) {
  return Promise.resolve(window.confirm((title ? title + '\n' : '') + (text || '')));
}

function swalAlert(text) {
  window.alert(text);
  return Promise.resolve();
}

function confirmFormSubmit(e, title, text) {
  e.preventDefault();
  if (window.confirm((title ? title + '\n' : '') + (text || ''))) {
    var form = e.target.closest('form') || e.target;
    form.submit();
  }
  return false;
}
