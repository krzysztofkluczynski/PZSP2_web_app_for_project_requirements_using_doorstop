%setdefault('stylesheet', None)
%setdefault('navigation', False)
<!DOCTYPE html>
<html>
<head><title>{{title or 'Doorstop'}}</title>
  <meta charset="utf-8" />
  <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
  <link rel="stylesheet" href="{{baseurl}}assets/doorstop/bootstrap.min.css" />
  <link rel="stylesheet" href="{{baseurl}}assets/doorstop/general.css" />
  <script src="https://kit.fontawesome.com/04e26bb3fa.js" crossorigin="anonymous"></script>
  {{! '<link type="text/css" rel="stylesheet" href="%s" />'%(baseurl+'assets/doorstop/'+stylesheet) if stylesheet else "" }}
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML" ></script>
  <script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {inlineMath: [["$","$"],["\\(","\\)"]]}
  });
  </script>
    <script>
    window.addEventListener('beforeunload', function(event) {
      // Send an AJAX request to your Flask server when the tab is closed
      var xhr = new XMLHttpRequest();
      xhr.open('POST', 'http://localhost:5000/closed_tab', true);
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.send(JSON.stringify({ 'closed_url': window.location.href }));
    });
  </script>
</head>
<body>
{{! '<P>Navigation: <a href="{0}">Home</a> &bull; <a href="{0}documents/">Documents</a>'.format(baseurl) if navigation else ''}}
  {{!base}}
<div class="commit"><form action="http://127.0.0.1:5000/commit" method="GET" target="frame"><input type="hidden" name="repo" value="{{str(repository)}}"><button type="submit" class="btn btn-primary btn-sm"> Commit </button></form></div><iframe name="frame" style="display: none;"></iframe>
</body>
</html>
