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
<div class="commit"><button type="submit" id="commitButton" class="btn btn-primary btn-sm" data-repo="{{str(repository)}}" data-toggle="modal" data-target="#commitModal"> Commit </button></div>
<div class="modal fade" id="commitModal" tabindex="-1" role="dialog" aria-labelledby="commitModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Commit</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <p id="commitStatus">Awaiting response...</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-dismiss="modal">OK</button>
      </div>
    </div>
  </div>
</div>
<script>
  $('#commitButton').on('click', async function (event) {
    var button = $(this)
    var repo = button.data('repo')
    $('#commitStatus').text('Awaiting response...')

    const response = await fetch("http://127.0.0.1:5000/commit", {
      method: "POST",
      body: JSON.stringify({
        repo: repo
      }),
      headers: {
        "Content-type": "application/json; charset=UTF-8"
      }
    })

    response.json().then(data => {
      var status = data.status
      var message = "Something went wrong"
      if (status == "success") {
        message = "Commit was successful"
      }
      $('#commitStatus').text(message)
    });
  })
</script>
</body>
</html>
