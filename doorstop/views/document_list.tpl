% rebase('base.tpl', title='Doorstop')
<H1>Doorstop - List of documents</H1>
<P>
<ul>
{{! "".join('<li><a href="{0}/items">{0}</a></li>'.format(p) for p in prefixes) }}
</ul>
    <script>
    window.addEventListener('beforeunload', function(event) {
      // Send an AJAX request to your Flask server when the tab is closed
      var xhr = new XMLHttpRequest();
      xhr.open('POST', 'http://localhost:5000/closed_tab', true);
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.send(JSON.stringify({ 'closed_url': window.location.href }));
    });
  </script>
</code>
