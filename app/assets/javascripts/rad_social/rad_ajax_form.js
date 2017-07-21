function RadAjaxForm(form) {
    var self = this;
    this.submitWithoutValidation = function(onSuccess, onError, onComplete) {
        if (onError === undefined) {
            onError = function() {
            };
        }
        if (onComplete === undefined) {
            onComplete = function() {
            };
        }

        form.find(".loader").addClass('ajax-loader');
        form.find(".loader-small").addClass('ajax-loader-small');
        $.ajax({
            type: "POST",
            url: form.find('input[name=submit_url]').attr('value'),
            data: form.serialize(),
          beforeSend: function ( xhr ) {
                xhr.setRequestHeader("X-CSRF-Token", $("#auth_token").attr('value'));
          },
            success: function(data, status, xhr) {
                form.find(".loader").removeClass('ajax-loader');
                form.find(".loader-small").removeClass('ajax-loader-small');
                onSuccess(data, status, xhr);
            },
            error: function(data) {
                form.find(".loader").removeClass('ajax-loader');
                form.find(".loader-small").removeClass('ajax-loader-small');
                form.find('.continue').attr('disabled', false);
                onError(data);
            },
            complete: onComplete
        });
        form.find('.continue').attr('disabled', 'disabled');
        return true;
    };

    this.defaultSubmitWithoutValidation = function() {
        this.submitWithoutValidation(handleSuccess, handleFailure);
    };

    this.submit = function(onSuccess, onError, onComplete) {
        if (onComplete === undefined) {
            onComplete = function() {
            };
        }

        if (onError === undefined) {
            onError = handleFailure;
        }

        if (!form.valid()) {
            onComplete();
            return true;
        }
        return self.submitWithoutValidation(onSuccess, onError, onComplete);
    };


    function handleSuccess(data, status, xhr)
    {
        var url = xhr.getResponseHeader("BrowserRedirectTo");
        if (!!url) {
          location.href = url
        }
    }

    function handleFailure(xhr) {
        var errorMessage = xhr.getResponseHeader("ErrorMsg");
        var errorMessageDialog = new ModalDialog('', function(element) {
            return {
                autoOpen: false,
                minHeight: 20,
                title: "We're Sorry!",
                dialogClass: 'seat-error-dialog'
            };
        });
        errorMessageDialog.show(errorMessage);
    }

}
