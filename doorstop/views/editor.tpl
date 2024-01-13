%setdefault('stylesheet', None)
%setdefault('navigation', False)
<!DOCTYPE html>
<html>
<head><title>Doorstop</title>
  <meta charset="utf-8" />
  <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
  <link rel="stylesheet" href="{{baseurl}}assets/doorstop/bootstrap.min.css" />
  <link rel="stylesheet" href="{{baseurl}}assets/doorstop/editor.css" />
  <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
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
{{! '<P>Navigation: <a href="{0}">Home</a> &bull; <a href="{0}documents/">Documents</a><br><button id="return-button">Return</button>'.format(baseurl) if navigation else ''}}
  <div id="item-id" prefix="{{str(prefix)}}" uid="{{str(uid)}}"></div>
  <div id="main-container">
    <div id="container">
        <div id="editor-container">
            <div id="title-container">
                <div id="header-container">
                  <h1 id="level" contenteditable="true">{{properties["level"]}}</h1>
                  <h1 style="min-width: 10px"></h1>
                  <h1 id="header" contenteditable="true" onclick="checkHeaderContent()" onblur="checkHeaderContent()" style="min-width: 100px">{{properties["header"]}}</h1>
                </div>
                <button id="preview-button" onclick="previewText()">Preview</button>
            </div>

            <textarea id="editor" placeholder="Enter a description in Markdown syntax...">{{properties["text"]}}</textarea>
            <div id="buttons-container">
              <div class="editor-buttons">
                  <button onclick="boldText()" value="B"><i class="fa-solid fa-bold"></i></button>
                  <button onclick="italicizeText()" value="I"><i class="fa-solid fa-italic"></i></button>
                  <button onclick="strikethroughText()" value="S"><i class="fa-solid fa-strikethrough"></i></button>
                  <button onclick="addPlantUML()">PlantUML</button>
              </div>
              <div class="save-button">
                  <button onclick="saveTextarea()">Save</button>
              </div>
            </div>
        </div>
        
        <div id="sidebar">
            <div id="links-container">
                <h2>Child links
                  <button id="links-button" value="+" style="font-size: 28px" onclick="openForm('child')"><i class="fa-solid fa-plus"></i></button>
                </h2>
                <ul class="link-list">
                    %for child in properties["child-links"]:
                      <li class="link">
                        <b>{{child[0]}}</b> <button id="links-button" value="-" onclick="deleteLink('{{child[0]}}', 'child')"><i class="fa-solid fa-xmark"></i></button><br>{{child[1]}}
                      </li>
                    %end
                </ul>
            </div>

            <div id="links-container">
                <h2>Parent links
                  <button id="links-button" value="+" style="font-size: 28px" onclick="openForm('parent')"><i class="fa-solid fa-plus"></i></button>
                </h2>
                <ul class="link-list">
                    %for parent in properties["parent-links"]:
                      <li class="link">
                        <b>{{parent[0]}}</b> <button id="links-button" value="-" onclick="deleteLink('{{parent[0]}}', 'parent')"><i class="fa-solid fa-xmark"></i></button><br>{{parent[1]}}
                      </li>
                    %end
                </ul>
            </div>

            <div id="links-container">
                <h2>External references</h2><br>
                  %if properties["ref"][0]:
                    <code style="margin-left: 10px">{{properties["ref"][0]}}</code> (line {{properties["ref"][1]}})
                  %end
            </div>

            <ul class="checkbox-list">
                <li class="checkbox">
                    <form>
                    <input type="checkbox" id="active" onchange="postCheckboxChange(this, 'active')" {{'checked' if properties["active"] else ''}}/>
                    <label for="active">Active</label>
                    </form>
                </li>
                <li class="checkbox">
                    <input type="checkbox" id="derived" onchange="postCheckboxChange(this, 'derived')" {{'checked' if properties["derived"] else ''}}/>
                    <label for="derived">Derived</label>
                </li>
                <li class="checkbox">
                    <input type="checkbox" id="normative" onchange="postCheckboxChange(this, 'normative')" {{'checked' if properties["normative"] else ''}}/>
                    <label for="normative">Normative</label>
                </li>
                <li class="checkbox">
                    <input type="checkbox" id="heading" onchange="postCheckboxChange(this, 'heading')" {{'checked' if properties["heading"] else ''}}/>
                    <label for="heading">Heading</label>
                </li>
            </ul>

        </div>
    </div>
    <div id="renderedOutput"></div>
  </div>
  <div id="myModal" data-linkType="">
    <div id="modalContent">
      <span id="closeButton" onclick="closeForm()">&times;</span>
      <h2>Enter an UID for new link:</h2><br>
      <form id="myForm">
        <label for="linkUID">UID:</label>
        <input type="text" id="linkUID" required>
        <button type="button" onclick="addLink()">Add</button>
      </form>
    </div>
  </div>
  <script src="{{baseurl}}assets/doorstop/editor.js"></script>
</body>
</html>
