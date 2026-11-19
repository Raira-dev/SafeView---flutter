// Contador de caracteres da descrição e botão de fechar dos alertas
(function () {
  var d = document.getElementById('descricao'), c = document.getElementById('contador');
  if (d && c) {
    var atualizar = function () { c.textContent = d.value.length; };
    d.addEventListener('input', atualizar);
    atualizar();
  }
  document.querySelectorAll('.alerta .fechar').forEach(function (b) {
    b.addEventListener('click', function () { b.parentElement.remove(); });
  });
})();
