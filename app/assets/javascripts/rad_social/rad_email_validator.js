function RadEmailValidator(parentElement) {
    var rules = {
        "rs-from": {
            required: true,
          email: true,
            messages: {
                required: "From email is required."
            }
        },
        "rs-from_name": {
            required: true,
            messages: {
                required: "From name is required."
            }
        },
        "rs-to": {
            required: true,
            email: true,
            messages: {
                required: "To email is required"
            }
        },
        "rs-message": {
            required: true,
            messages: {
                required: "Email message is required."
            }
        }
    };

    this.addRules = function() {
        for (var key in rules) {
            $(parentElement).find("[id$=" + key + "]").rules("add", rules[key]);
        }
    };

    this.removeRules = function() {
        for (var key in rules) {
            $(parentElement).find("[id$=" + key + "]").rules("remove");
        }
    };

    function elementKeyFor(key) {
        return "[id$=" + parentElement.attr('id') + '_' + key + ']';
    }

}
