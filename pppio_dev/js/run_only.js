function betterTab(cm) {
    if (cm.somethingSelected()) {
        cm.indentSelection("add");
    } else {
        cm.replaceSelection(
            cm.getOption("indentWithTabs") ? "\t" :
                Array(cm.getOption("indentUnit") + 1).join(" "), "end", "+input");
    }
}

var editor = CodeMirror.fromTextArea(document.getElementById("code"), {
    mode: {
        name: "python",
        version: 2,
        singleLineStringErrors: false
    },
    lineNumbers: true,
    indentUnit: 4,
    matchBrackets: true,
    theme: "default",
    extraKeys: { Tab: betterTab }
});

document.getElementById("runButton").onclick = function () {
    clearAlerts();

    //Save where the cursor is and where the code editor is scrolled to
    var curPos = editor.getDoc().getCursor();
    var scrollPos = editor.getScrollInfo();

    //Clear whatever is currently drawn
    if (Sk.TurtleGraphics !== undefined && Sk.TurtleGraphics.reset !== undefined) {
        Sk.TurtleGraphics.reset();
    }

    //Replace tabs with 4 spaces 
    editor.setValue(editor.getValue().replace(/\t/g, '    '));

    //Set the cursor and scrollbar position to where they were before the run button was pressed
    editor.getDoc().setCursor(curPos);
    editor.scrollTo(0, scrollPos.top);

    run();
};

/*
uncomment to disable copy/paste for projects
editor.on('copy', function(a, e) {e.preventDefault();});
editor.on('cut', function(a, e) {e.preventDefault();});
editor.on('paste', function(a, e) {e.preventDefault();});
*/

function builtinRead(x) {
    if (Sk.builtinFiles === undefined || Sk.builtinFiles["files"][x] === undefined)
        throw "File not found: '" + x + "'";
    return Sk.builtinFiles["files"][x];
}

function run() {
    var program = editor.getValue() + '\n';
    var outputArea = document.getElementById("output");
    outputArea.innerHTML = '';
    Sk.pre = "output";
    Sk.configure({
        output: outf,
        read: builtinRead,
        inputfun: inf,
        inputfunTakesPrompt: true,
    });
    (Sk.TurtleGraphics || (Sk.TurtleGraphics = {})).target = 'mycanvas';
    var myPromise = Sk.misceval.asyncToPromise(function () {
        return Sk.importMainWithBody("<stdin>", false, program, true);
    });
    myPromise.then(function (mod) { },
        function (err) {
            markError(err.toString());
        });

    //Delays the function that creates the drawing area by 750ms to allow the other elements to be created by the time this code runs
    //This will get the calculate the size the text output area needs to be by getting the total height of the right column and subtracting
    //the size of the drawing area
    setTimeout(function () {
        var canvas = document.getElementById("mycanvas");
        var canHeight = canvas.offsetHeight;
        var canParHeight = canvas.parentNode.clientHeight;
        outputArea.style.height = (canParHeight - canHeight) + "px";
    }, 750);
}
var codeAlerts = document.getElementById('codeAlerts');

function clearAlerts() {
    codeAlerts.innerHTML = '';
}

function markError(errorMessage) {
    if (typeof errorCount !== "undefined") {
        errorCount += 1;
    }
    codeAlerts.innerHTML += '<div class="alert alert-danger alert-dismissible mar-0" role="alert" id="infoAlert">' + errorMessage + '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button></div>';
}

function markSuccess(successMessage) {
    codeAlerts.innerHTML += '<div class="alert alert-success alert-dismissible mar-0" role="alert" id="infoAlert">' + successMessage + '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button></div>';
}
