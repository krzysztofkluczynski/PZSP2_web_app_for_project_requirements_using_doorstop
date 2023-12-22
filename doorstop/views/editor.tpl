%setdefault('stylesheet', None)
%setdefault('navigation', False)
<!DOCTYPE html>
<html>
<head><title>Doorstop</title>
  <meta charset="utf-8" />
  <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
  <link rel="stylesheet" href="{{baseurl}}assets/doorstop/bootstrap.min.css" />
  <link rel="stylesheet" href="{{baseurl}}assets/doorstop/editor.css" />
  <script src="https://kit.fontawesome.com/04e26bb3fa.js" crossorigin="anonymous"></script>
  {{! '<link type="text/css" rel="stylesheet" href="%s" />'%(baseurl+'assets/doorstop/'+stylesheet) if stylesheet else "" }}
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML" ></script>
  <script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {inlineMath: [["$","$"],["\\(","\\)"]]}
  });
  </script>
</head>
<body>
{{! '<P>Navigation: <a href="{0}">Home</a> &bull; <a href="{0}documents/">Documents</a>'.format(baseurl) if navigation else ''}}

  <div id="container">
      <div id="editor-container">
          <div id="title-container">
              <h1>3.4 Untitled</h1>
              <button id="preview-button" onclick="previewText()">Preview</button>
          </div>

          <textarea id="editor" placeholder="Wpisz tutaj w składni Markdown..."></textarea>
          <div class="editor-buttons">
              <button onclick="boldText()" value="B"><i class="fa-solid fa-bold"></i></button>
              <button onclick="italicizeText()" value="I"><i class="fa-solid fa-italic"></i></button>
              <button onclick="underlineText()" value="U"><i class="fa-solid fa-underline"></i></button>
              <button onclick="skreslText()" value="S"><i class="fa-solid fa-strikethrough"></i></button>
          </div>
      </div>
      
      <div id="sidebar">
          <div id="links-container">
              <h2>Child links</h2>
              <ul class="link-list">
                  <li class="link">
                      <a href="#">link 1</a>
                  </li>
                  <li class="link">
                      <a href="#">link 2</a>
                  </li>
                  <li class="link">
                      <a href="#">link 3</a>
                  </li>
              </ul>
          </div>

          <div id="links-container">
              <h2>Parent links</h2>
              <ul class="link-list">
                  <li class="link">
                      <a href="#">link 1</a>
                  </li>
                  <li class="link">
                      <a href="#">link 2</a>
                  </li>
                  <li class="link">
                      <a href="#">link 3</a>
              </ul>
          </div>

          <div id="links-container">
              <h2>External references</h2>
              <ul class="link-list">
                  <li class="link">
                      <a href="#">link 1</a>
                  </li>
                  <li class="link">
                      <a href="#">link 2</a>
                  </li>
                  <li class="link">
                      <a href="#">link 3</a>
                  </li>
              </ul>
          </div>

          <ul class="checkbox-list">
              <li class="checkbox">
                  <input type="checkbox" id="active" />
                  <label for="active">Active</label>
              </li>
              <li class="checkbox">
                  <input type="checkbox" id="derived" />
                  <label for="derived">Derived</label>
              </li>
              <li class="checkbox">
                  <input type="checkbox" id="normative" />
                  <label for="normative">Normative</label>
              </li>
              <li class="checkbox">
                  <input type="checkbox" id="heading" />
                  <label for="heading">Heading</label>
              </li>
          </ul>

      </div>
  </div>

  <script src="{{baseurl}}assets/doorstop/editor.js"></script>
</body>
</html>
