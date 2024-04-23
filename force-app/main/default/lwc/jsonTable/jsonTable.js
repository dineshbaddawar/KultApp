import { LightningElement, api } from 'lwc';

export default class JsonTable extends LightningElement {
    @api jsonData;
    @api docTempName;
    Namedoc;
    hidePindCodeSeriveValue = true;
    hideOutOfStock = true;
    hidecourierDeliveryIssue = true;
    hidelostinTransit = true;
    hideRTOOrder = true;
    getSerialNumber(index) {
        return index + 1;
    }
    connectedCallback() {
        debugger;
        this.Namedoc = this.docTempName;
        if (this.Namedoc == 'PinCodeService') {
            this.hidePindCodeSeriveValue = false;
        } else {
            this.hidePindCodeSeriveValue = true;
        }

        if (this.Namedoc == 'OutOfStock') {
            this.hideOutOfStock = false;
        } else {
            this.hideOutOfStock = true;
        }

        if (this.Namedoc == 'DeliveryIssue') {
            this.hidecourierDeliveryIssue = true;
            this.hidePindCodeSeriveValue = false;
        } else {
            this.hidecourierDeliveryIssue = false;
        }

        if (this.Namedoc == 'LostInTransit' || this.Namedoc == 'DeleayInDelivery') {
            this.hidelostinTransit = true;
            this.hidePindCodeSeriveValue = false;
            this.hideOutOfStock = false;
        } else {
            this.hidelostinTransit = false;
        }

        if (this.Namedoc == 'RToOrders') {
            this.hideRTOOrder = true;
            this.hidePindCodeSeriveValue = false;
            this.hideOutOfStock = false;
        } else {
            this.hideRTOOrder = false;
        }

    }
}