import { LightningElement, api } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import excelFileReader from "@salesforce/resourceUrl/ExcelReaderPlugin";
let XLS = {};
import insertBulkCaseXlsxFiel from '@salesforce/apex/BulkCaseUploadController.insertBulkCaseXlsxFiel';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BulkCaseUploadURL	 from '@salesforce/label/c.BulkCaseUploadURL';

export default class BulkCaseRecordUploadXlsx extends LightningElement {
     error;
     data;
     jsonData = [];
     showTable = false;
     showUploadFile = true;
     @api docTempName;
     BulkCaseUploadURL = BulkCaseUploadURL;

     strAcceptedFormats = [".xls", ".xlsx"];
     strUploadFileName;
     objExcelToJSON;
     convertedDate;
     stringifyconvertedDate;

     connectedCallback() {
          debugger;
          this.docTempName = this.docTempName;
          Promise.all([loadScript(this, excelFileReader)])
               .then(() => {
                    XLS = XLSX;
               })
               .catch((error) => {
                    console.log("An error occurred while processing the file");
               });
     }

     @api
     handleFileUpload(event) {
          debugger;
          console.log(event);
          this.handleUploadFinished(event);
     }
     handleUploadFinished(event) {
          debugger;
          const strUploadedFile = event.detail.files;
          if (strUploadedFile.length && strUploadedFile != "") {
               this.strUploadFileName = strUploadedFile[0].name;
               var extension = this.strUploadFileName.split('.').pop();
               this.handleProcessExcelFile(strUploadedFile[0]);
          }
     }

     handleProcessExcelFile(file) {
          debugger;
          let objFileReader = new FileReader();
          objFileReader.onload = (event) => {
               let objFiledata = event.target.result;
               let objFileWorkbook = XLS.read(objFiledata, {
                    type: "binary"
               });
               this.objExcelToJSON = XLS.utils.sheet_to_row_object_array(
                    objFileWorkbook.Sheets["Sheet1"]
               );
               if (this.objExcelToJSON.length === 0) {
                    this.strUploadFileName = "";
                    this.dispatchEvent(
                         new ShowToastEvent({
                              title: "Error",
                              message: "Kindly upload the file with data",
                              variant: "error"
                         })
                    );
               }
               if (this.objExcelToJSON.length > 0) {
                    Object.keys(this.objExcelToJSON).forEach((key) => {
                         const replacedKey = key.trim().toUpperCase().replace(/ss+/g, "_");
                         if (key !== replacedKey) {
                              this.objExcelToJSON[replacedKey] = this.objExcelToJSON[key];
                              delete this.objExcelToJSON[key];
                         }
                    });
                    debugger;
                    console.log('objExcelToJSON' + this.objExcelToJSON);
                    let data = JSON.parse(JSON.stringify(this.objExcelToJSON));
                    let objList = [];
                    let index = 0;
                    for (var i = 0; i < data.length; i++) {
                         index += 1;
                         this.convertedDate = new Date((data[i]["Date Of Order"] - 25569) * 86400 * 1000);
                         this.stringifyconvertedDate = JSON.stringify(this.convertedDate);

                         const year = this.stringifyconvertedDate.slice(1, 5);
                         const month = this.stringifyconvertedDate.slice(6, 8);
                         const day = this.stringifyconvertedDate.slice(9, 11);

                         // Create the desired format
                         const formattedDate = `${day}-${month}-${year}`;

                         var obj = {
                              "orderno": data[i]["Order No"],
                              "dateoforder": formattedDate,
                              "shippingmobileno": data[i]["Shipping Mobile No"],
                              "reason": data[i]["Reason"],
                              "item": data[i]["Item"],
                              "oosquantity": data[i]["OOS Quantity"],
                              "oosskucode": data[i]["OOS SKU Code"],
                              "remarks": data[i]["Remarks"],
                              "currentpincode": data[i]["Current PIN Code"],   
                              "cityname": data[i]["City Name"], 
                              "awbnumber": data[i]["AWB Number"],
                              "courierpartner": data[i]["Courier Partner"], // 
                              "orderstatus": data[i]["Order Status"],
                              "sno": index
                         };
                         objList.push(obj);
                    }
                    console.log('data == ' + objList);
                    this.jsonData = objList;
                    this.showTable = true;
                    this.showUploadFile = false;
                    // this.callInsertAccountRecords();
               }
          };

          objFileReader.onerror = function (error) {
               this.dispatchEvent(
                    new ShowToastEvent({
                         title: "Error while reading the file",
                         message: error.message,
                         variant: "error"
                    })
               );
          };
          objFileReader.readAsBinaryString(file);
     }

     closeAction() {
          debugger;
          window.location.href = this.BulkCaseUploadURL;
     }

     HandleImportRecord() {
          debugger;
          insertBulkCaseXlsxFiel({ jsonString: JSON.stringify(this.jsonData), docTempName: this.docTempName })
               .then(result => {
                    if (result) {
                         
                         this.showToast();
                    } else {
                         alert('Error');
                    }
               })
               .catch(error => {
                    this.error = error;
               })
     }

     showToast() {
          const event = new ShowToastEvent({
              title: 'SUCCESS',
              message: 'Record Created Successfully !',
              variant: 'success',
              mode: 'dismissable'
          });
          this.dispatchEvent(event);
          setTimeout(() => {
               window.location.href = this.BulkCaseUploadURL;
          }, 2000);
      }

}