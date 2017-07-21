function Captcha(element) {
    var self = this;
    var challengeFieldSelector = "#recaptcha_challenge_field";
    var responseFieldSelector = "#recaptcha_response_field";

    self.challengeValue = function() {
        return $(element).find(challengeFieldSelector).val();
    };

    self.responseValue = function() {
        return $(element).find(responseFieldSelector).val();
    };

    self.visible = function() {
        return ($(element).find("#recaptcha_area").length > 0);
    };

    self.requestData = function() {
        requestHash = {};
        if(this.visible()) {
            $.extend(requestHash, {
                'recaptcha_challenge_field': this.challengeValue(),
                'recaptcha_response_field': this.responseValue()
            });
        }
        return requestHash;
    };

    self.isValid = function() {
        if(this.visible()) {
            return this.responseValue().length > 0;
        }
        return true;
    };

    self.reload = function() {
        if(Recaptcha) {
            Recaptcha.reload();
        }
    };

}