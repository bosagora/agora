//
// setup.dt support code
//
// 'setup' is a single-page application, built from scratch.
// The following code supports navigation as well as individual panels interactions.
//

"use strict";

////////////////////////////////////////////////////////////////////////////////
// Generic functions
////////////////////////////////////////////////////////////////////////////////

// Check that a type conforms to a specific value
//
// Params:
//   e = Instance of the element to check
//   t = Expected type of e (string)
//   n = Parameter name (string, default to "parameter")
function checkType(i, t, n) {
    if (typeof(t) != "string")
        throw new TypeError("Expected string argument for 't' argument, not: " + typeof(t));
    if (typeof(n) != "string")
        n = "parameter";
    if (typeof(i) != t)
        throw new TypeError("Expected " + t + " argument for '" + n + "', not: " + typeof(i));
}

// Poor man's assertion
//
// Replace the page's HTML with an assertion error message.
function assert(boolv, message) {
    try {
        checkType(message, "string", "message");
        if (!boolv)
            throw new Error(message);
    } catch (err) {
        let msg = "<h1>An error has happened<h1>" +
            "<p>Please report on <a href='https://github.com/bpfkorea/agora'>our Github</a> " +
            "and include the following message:<br>" + err.message + "</p>";
        //document.body.innerHTML = msg;
        window.alert(msg);
        throw err;
    }
}

////////////////////////////////////////////////////////////////////////////////
// Seed panel functions
////////////////////////////////////////////////////////////////////////////////

class SeedPanel {
    constructor(jqRoot) {
        this.isValid_ = undefined;
        this.root = jqRoot;
    }

    get isValid() {
        return this.isValid_;
    }

    set isValid(val) {
        checkType(val, "boolean", "val");
        if (val)
            $("#continue").removeClass("disabled");
        else
            $("#continue").addClass("disabled");
        this.isValid_ = val;
    }

    // Called when this panel is loaded
    onLoad() {
        if (typeof this.isValid_ === 'undefined')
            this.root.find("input+.card").first().trigger('click');
        checkType(this.isValid_, 'boolean', 'this.isValid_');
    }

    // Called on switch between validator / full node radio
    handleCardChange(current) {
        let isFullNode = (current.getAttribute('value') !== "true");
        $('#seed').prop("disabled", isFullNode);
        if (!isFullNode)
        {
            this.root.find(".field-container").removeClass("disabled");
            this.handleFormChange(document.getElementById('seed'));
        }
        else
        {
            this.root.find(".field-container").addClass("disabled");
            this.isValid = true;
        }
    }

    // Called from seed panel to validate the format of the seed
    //
    // If the seed is invalid, the 'continue' button/link is set to disabled.
    // Called by the input (as `self`)
    handleFormChange(self) {
        this.isValid = SeedPanel.isValidSeed(self.value);
    }

    // Check if a seed is valid
    static isValidSeed(value) {
        return /^S[0-9a-z]{55}$/i.test(value);
    }
}

////////////////////////////////////////////////////////////////////////////////
// Network options panel functions
//
// TODO: Validate address / DNS values
////////////////////////////////////////////////////////////////////////////////

class NetworkPanel {
    constructor(jqRoot) {
        this.root = jqRoot;
    }

    // Called when this panel is loaded
    onLoad() {
        // Do nothing
    }
}

////////////////////////////////////////////////////////////////////////////////
// Panel to configure the ban manager
////////////////////////////////////////////////////////////////////////////////

class BanManPanel {
    constructor(jqRoot) {
        this.root = jqRoot;
    }

    // Called when this panel is loaded
    onLoad() {
        // Do nothing
    }
}

////////////////////////////////////////////////////////////////////////////////
// Panel to configure the address at which the administrative interface listen
////////////////////////////////////////////////////////////////////////////////

class AdminNetPanel {
    constructor(jqRoot) {
        this.root = jqRoot;
    }

    // Called when this panel is loaded
    onLoad() {
        // Do nothing
    }
}

////////////////////////////////////////////////////////////////////////////////
// Single Page Application class
////////////////////////////////////////////////////////////////////////////////

// Handles our single page application
//
// Holds the global data and navigation-related utilities.
class SPA {
    // Constructor
    constructor() {
        this._step = 0;
        this._maxStep = 0;

        // Seed panel
        this.panels = [
            new SeedPanel($('#panel > div:nth-child(1)')),
            new NetworkPanel($('#panel > div:nth-child(2)')),
            new BanManPanel($('#panel > div:nth-child(3)')),
            new AdminNetPanel($('#panel > div:nth-child(4)')),
        ];
    }

    // Getter for the step we're at
    get step() {
        return this._step;
    }

    // Return the current step object
    get current() {
        return this.panels[this._step];
    }

    // Move the current panel to another step
    //
    // Takes care of updating the panel property and setting the panel's
    // default properties.
    navigate(v) {
        checkType(v, "number", "v");
        assert(v >= 0, "Trying to navigate to negative offset");
        assert(v <= this._maxStep + 1, "User attempting to navigate past maxStep");
        assert(v < this.panels.length, "User attempting to navigate past end of SPA");

        // Index for 'nth-child' is 1-based
        const childIdx = (v + 1);
        $('#nav > a').each((idx, elem) => $(elem).removeClass('active'));
        $('#nav a:nth-child(' + childIdx + ')').addClass('active').prop("aria-selected", true);
        $('#panel > div').each((idx, elem) => $(elem).hide());
        $('#panel > div:nth-child(' + childIdx + ')').show();

        this._step = v;
        if (this._maxStep <= this._step)
            this._maxStep = v;
        SPA.setMaxNavLink(this._maxStep);
        this.current.onLoad();
    }

    // Goes one step forward
    forward() {
        if (this._step < (this.panels.length - 1))
            this.navigate(this._step + 1);
        else
            this.submit();
    }

    // Goes one step backward, or to `welcome`
    backward() {
        if (this._step <= 0)
            window.location.href = "/welcome";
        else
            this.navigate(this._step - 1);
    }

    /// Commit the configuration to the backend
    submit() {
        const seed = document.getElementById('seed').value;

        // TODO: Some of those values need to be properly filled in
        // For the moment we use placeholders to pass validation.
        const node_url = new URL(SPA.readProp(document.getElementById('inetwork')));
        let config = {
            banman: {
                max_failed_requests: SPA.readProp(document.getElementById('ban_tolerance')),
                ban_duration: SPA.readProp(document.getElementById('ban_duration')) * 1000,
            },
            node: {
                is_validator: (seed.length != 0),
                min_listeners: 2,
                max_listeners: 10,
                address: node_url.hostname,
                port: node_url.port,
            },
            admin: {},
            network: [ 'http://192.168.1.42:2828' ],
            dns_seeds: [], // Optional
            quorum: {
                threshold: "66%",
                // 'nodes' is actually optional, although it shouldn't be
            },
            logging: {},
        };

        $.ajax({
            method: 'POST',
            url: '/create',
            async: false,
            contentType: 'application/yaml',
            data: jsyaml.safeDump(config),
            success: function(data, textStatus, jqXHR){
                window.alert("Config file successfully written, you can close this window");
            },
            error: function(jqXHR, textStatus, errorThrown){
                window.alert("Writing the config file failed: " + textStatus + ": " + errorThrown);
            },
        });
    }

    // Set which link is the "highest" link activated.
    // Idx is 0 based, based on the `panels` in SPA.
    static setMaxNavLink(maxStep) {
        checkType(maxStep, "number", "maxStep");
        $('#nav > a').each(function(idx, elem) {
            if (idx <= maxStep)
                $(elem).removeClass('disabled');
            else
                $(elem).addClass('disabled');
        });
    }

    // Read a property with a default value (as a placeholder)
    static readProp(elem) {
        checkType(elem.value, "string", "element.value");
        if (elem.value.length)
            return elem.value;
        assert(elem.placeholder.length > 0, "No placeholder text for: " + elem);
        return elem.placeholder;
    }
}

var spa = new SPA();
$('document').ready(spa.navigate(0));
