% rebase('base.tpl', title='Doorstop')
<H1>Doorstop - List of items in {{prefix}}</H1>
<P>
<ul>

%for i in items:
    <li><a href="items/{{i}}">{{i}}</a> <form action="/documents/{{prefix}}/items" method=POST> <input type ="submit" name="Delete" value="Delete"> <input type ="hidden" name="item" value="{{i}}"> </form> </li>
%end
    <script>
    window.addEventListener('beforeunload', function(event) {
      // Send an AJAX request to your Flask server when the tab is closed
      var xhr = new XMLHttpRequest();
      xhr.open('POST', 'http://localhost:5000/closed_tab', true);
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.send(JSON.stringify({ 'closed_url': window.location.href }));
    });
  </script>
</ul>
</code>
