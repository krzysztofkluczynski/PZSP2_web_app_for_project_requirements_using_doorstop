% rebase('base.tpl', title='Doorstop')
<H1>Doorstop - Index</H1>
<P>
{{!tree_code}}
<div class="modal fade" id="addDocumentModal" tabindex="-1" role="dialog" aria-labelledby="addDocumentModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="addDocumentModalLabel">New document</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <form>
          <div class="form-group">
            <label for="document-name" class="col-form-label">Prefix of the new document:</label>
            <input type="text" class="form-control" id="document-name">
          </div>
          <div class="form-group">
            <label for="document-parent" class="col-form-label">Parent:</label>
            <input type="text" class="form-control" id="document-parent">
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
        <button type="button" class="btn btn-primary" id="documentCreateSubmit">Create</button>
      </div>
    </div>
  </div>
</div>
<script src="{{baseurl}}assets/doorstop/jquery.min.js"></script>
<script src="{{baseurl}}assets/doorstop/bootstrap.min.js"></script>
<script>
  $('#addDocumentModal').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget) // Button that triggered the modal
    var parent = button.data('parent') // Extract info from data-* attributes - parent document prefix
    var modal = $(this)
    modal.find('#document-parent').val(parent)
    // modal.find('.modal-title').text('New document (child of ' + parent + ')')
    // modal.find('.modal-body input').val(recipient)
  })

$('#documentCreateSubmit').on('click', function (event) {
    var parent = $('#document-parent').val()
    var newDoc = $('#document-name').val()

    fetch("/", {
      method: "POST",
      body: JSON.stringify({
        parent: parent,
        name: newDoc,
      }),
      headers: {
        "Content-type": "application/json; charset=UTF-8"
      }
    }).then(location.reload());
  })
</script>
