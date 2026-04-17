<?php
require __DIR__ . '/vendor/autoload.php';

use Mike42\Escpos\Printer;
use Mike42\Escpos\EscposImage;
use Mike42\Escpos\PrintConnectors\WindowsPrintConnector;

class item
{
    private $name;
    private $price;
    private $dollarSign;

    public function __construct($name = '', $price = '', $dollarSign = false)
    {
        $this->name = $name;
        $this->price = $price;
        $this->dollarSign = $dollarSign;
    }

    public function __toString()
    {
        $rightCols = 10;
        $leftCols = 38;
        if ($this->dollarSign) {
            $leftCols = $leftCols / 2 - $rightCols / 2;
        }
        $left = str_pad($this->name, $leftCols);

        $sign = ($this->dollarSign ? '$ ' : '');
        $right = str_pad($sign . $this->price, $rightCols, ' ', STR_PAD_LEFT);
        return "$left$right\n";
    }
}

$printerName = 'comerciandoPrinter';
$connector = new WindowsPrintConnector($printerName);
$printer = new Printer($connector);

$items = array(
    new item("Example item #1", "4.00"),
    new item("Another thing", "3.50"),
    new item("Something else", "1.00"),
    new item("A final item", "4.45"),
);
$subtotal = new item('Subtotal', '12.95');
$tax = new item('A local tax', '1.30');
$total = new item('Total', '14.25', true);
$date = "Monday 6th of April 2015 02:56:25 PM";

/* Print optional logo from file instead of embedded base64 payload */
$logoPath = __DIR__ . '/resources/logo.png';
if (is_file($logoPath)) {
    $logo = EscposImage::load($logoPath, false);
    $printer->setJustification(Printer::JUSTIFY_CENTER);
    $printer->graphics($logo);
}

$printer->selectPrintMode(Printer::MODE_DOUBLE_WIDTH);
$printer->text("ExampleMart Ltd.\n");
$printer->selectPrintMode();
$printer->text("Shop No. 42.\n");
$printer->feed();

$printer->setEmphasis(true);
$printer->text("SALES INVOICE\n");
$printer->setEmphasis(false);

$printer->setJustification(Printer::JUSTIFY_LEFT);
$printer->setEmphasis(true);
$printer->text(new item('', '$'));
$printer->setEmphasis(false);
foreach ($items as $item) {
    $printer->text($item);
}
$printer->setEmphasis(true);
$printer->text($subtotal);
$printer->setEmphasis(false);
$printer->feed();

$printer->text($tax);
$printer->selectPrintMode(Printer::MODE_DOUBLE_WIDTH);
$printer->text($total);
$printer->selectPrintMode();

$printer->feed(2);
$printer->setJustification(Printer::JUSTIFY_CENTER);
$printer->text("Thank you for shopping at ExampleMart\n");
$printer->text("For trading hours, please visit example.com\n");
$printer->feed(2);
$printer->text($date . "\n");

$printer->feed(2);
$printer->barcode("ABC", Printer::BARCODE_CODE39);
$printer->feed();

$printer->cut();
$printer->pulse();
$printer->close();
