function editText(specialCharacters) {
    /*
    function adds (or removes when already exists) special characters, like "**"
    before and after selected text,
    or before and after a word, on which we have our cursor currently
    */
    
    var len = specialCharacters.length;
    var textarea = document.getElementById("editor");
    var start = textarea.selectionStart;
    var end = textarea.selectionEnd;

    //highlighted text
    if (start !== undefined && end !== undefined && start !== end) {
        var selectedText = textarea.value.substring(start, end);

        var textBeforeSelection = textarea.value.substring(0, start);
        var textAfterSelection = textarea.value.substring(end);

        //word already surrounded by specialCharacters
        if (selectedText.startsWith(specialCharacters) && selectedText.endsWith(specialCharacters)) {
            var newText = textarea.value.substring(0, start) + selectedText.slice(len, -len) + textarea.value.substring(end);
            textarea.value = newText;
            textarea.setSelectionRange(start, end - 2*len);
        }
        else if (textBeforeSelection.endsWith(specialCharacters) && textAfterSelection.startsWith(specialCharacters)) {
            var newText = textarea.value.substring(0, start - len) + selectedText + textarea.value.substring(end + len);
            textarea.value = newText;
            textarea.setSelectionRange(start - len, end - len);
        }
        else {
            var newText = textarea.value.substring(0, start) + specialCharacters + selectedText + specialCharacters + textarea.value.substring(end);
            textarea.value = newText;
            textarea.setSelectionRange(start + len, end + len);
        }

    //nothing highlighted
    } else {
        var textBeforeCursor = textarea.value.substring(0, start);
        var textAfterCursor = textarea.value.substring(start);
        var wordBeforeCursor = textBeforeCursor.replace(/[\s\S]*\s/, '');
        var wordAfterCursor = textAfterCursor.replace(/\s[\s\S]*/, '');

        //cursor not on a word
        if (wordBeforeCursor.length === 0 || wordAfterCursor.length === 0) {
            textarea.focus();
            return;
        }

        //word already surrounded by specialCharacters
        if (wordBeforeCursor.startsWith(specialCharacters) && wordAfterCursor.endsWith(specialCharacters)) {
            var newText = textBeforeCursor.slice(0, -wordBeforeCursor.length) + wordBeforeCursor.slice(len) + wordAfterCursor.slice(0, -len) + textAfterCursor.slice(wordAfterCursor.length);
            textarea.value = newText;
            textarea.selectionEnd = end - len;
        } else {
            var newText = textBeforeCursor.slice(0, -wordBeforeCursor.length) + specialCharacters + wordBeforeCursor + wordAfterCursor + specialCharacters + textAfterCursor.slice(wordAfterCursor.length);
            textarea.value = newText;
            textarea.selectionEnd = end + len;
        }

    }
    textarea.focus();
}

function boldText() {
    editText("**");    
}

function italicizeText() {
    editText("*");
}

function strikethroughText() {
    editText("~~");
}

function addPlantUML() {
    var textarea = document.getElementById("editor");
    var start = textarea.selectionStart;
    var textBeforeCursor = textarea.value.substring(0, start);
    var textAfterCursor = textarea.value.substring(start);

    var newText = textBeforeCursor + "\n```plantuml\n@startuml\n\n@enduml\n```\n" + textAfterCursor;
    textarea.value = newText;
    textarea.selectionEnd = start + 23;

    textarea.focus();
}

function previewText() {
    var inputText = document.getElementById("editor").value;
    var renderedText = marked.parse(inputText);
    document.getElementById("renderedOutput").innerHTML = renderedText;
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

function saveTextarea(prefix, uid) {
    var textarea = document.getElementById("editor").value;

    var xhr = new XMLHttpRequest();
    xhr.open("POST", "/documents/" + prefix + "/items/" + uid + "/edit", true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify({
        action: "modify-text",
        content: textarea
    }));

    alert("zapisano...");

}
