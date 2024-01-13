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

function postCheckboxChange(checkboxElem, action) {
    data = {
        action: action,
        state: checkboxElem.checked
    }
    postToEditor(data);
}

function saveTextarea() {
    var textarea = document.getElementById("editor").value;

    data = {
        action: "modify-text",
        content: textarea
    }
    postToEditor(data);

    alert("zapisano...");
}

function checkHeaderContent() {
    var header = document.getElementById("header");
    console.log("in check header functuon")
    if (!header.textContent.trim()) {
        header.textContent = "Type header here";
        header.classList.add("placeholder");
    } else if (header.textContent == "Type header here"){
        header.classList.remove("placeholder");
        header.textContent = "";
    }
}

function deleteLink(uid, type) {
    data = {
        action: "delete-link",
        uid: uid,
        type: type
    }
    postToEditor(data);
}

function addLink() {
    var uid = document.getElementById("linkUID").value;
    var linkType = document.getElementById("myModal").dataset.linkType;

    data = {
        action: "add-link",
        uid: uid,
        type: linkType
    }
    postToEditor(data)
    closeForm();
}

function openForm(linkType) {
    document.getElementById("myModal").style.display = "block";
    document.getElementById("myModal").dataset.linkType = linkType;
}

function closeForm() {
    document.getElementById("myModal").style.display = "none";
    document.getElementById("linkUID").value = "";
}

var levelHeading = document.getElementById("level");
levelHeading.addEventListener("input", function() {
    var levelValue = levelHeading.innerText;

    data = {
        action: "modify-level",
        content: levelValue
    }
    postToEditor(data);
});


var headerHeading = document.getElementById("header");
headerHeading.addEventListener("input", function() {
    var headerValue = headerHeading.innerText;

    data = {
        action: "modify-header",
        content: headerValue
    }
    postToEditor(data);
});

function postToEditor(data) {
    var item_data = document.getElementById("item-id");
    var prefix = item_data.getAttribute("prefix");
    var uid = item_data.getAttribute("uid");

    fetch(`/documents/${prefix}/items/${uid}/edit`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else if (!data.success) {
            alert("UID not found!");
        }
    })
    .catch((error) => {
        console.error('Error:', error);
    });
}

var returnButton = document.getElementById("return-button");
returnButton.addEventListener("click", function() {
    var item_data = document.getElementById("item-id");
    var prefix = item_data.getAttribute("prefix");
    window.location.href = "/documents/" + prefix;
})

checkHeaderContent();
