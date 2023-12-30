function boldText() {
    document.getElementById("editor").style.fontWeight = "bold";
}

function italicizeText() {
    document.getElementById("editor").style.fontStyle = "italic";
}

function underlineText() {
    document.getElementById("editor").style.textDecoration = "underline";
}

function skreslText() {
    document.getElementById("editor").style.textDecoration = "underine"; //do zmiany
}

function previewText() {
    // dodać render
    alert("Render");
}

function postCheckboxChange(checkboxElem, prefix, uid, action) {
    if (checkboxElem.checked) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "/documents/" + prefix + "/items/" + uid + "/edit", true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send(JSON.stringify({
            action: action,
            state: true
        }));

    }
    else {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "/documents/" + prefix + "/items/" + uid + "/edit", true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.send(JSON.stringify({
            action: action,
            state: false
        }));
    }
}
