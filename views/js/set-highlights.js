var toggleState = false;

window.addEventListener('load', function () {

    var button = document.getElementById('highlightTemplate');

    button.addEventListener ('click', function() {

        var nodes = document.querySelectorAll ('[data-set-repeat], [data-set-text], [data-set-attr], [data-set-if^="error"], [data-set-if^="not:"], [data-set-repeat], [data-set-if="false"], [data-set-dummy]');

        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i];
            if (!toggleState) {
                node.classList.add('show');
            } else {
                node.classList.remove('show');
            }
        }

        // Special case: although the Show highlights button is, itself, an element
        // ============= that will not show in the final template, let’s not dim it
        //               as it might look disabled to the user. Also it is clearly
        //               demarcated from the rest of the document as a control so it
        //               won’t be mistaken for a document item.
        //
        // NB. Also added the template summary to the special case.
        document.getElementById('setControls').classList.remove('show')
        document.getElementById('set-template-summary').classList.remove('show')

        toggleState = !toggleState;
        button.innerHTML = (toggleState ? 'Hide' : 'Show') + ' highlights';
    });
});
