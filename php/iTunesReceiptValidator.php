<?php
require __DIR__ . '/vendor/autoload.php';


$receipt = $_POST['receipt'];
$sandbox = false;
if (array_key_exists('sandbox',$_GET)) {
	$sandbox = $_GET['sandbox'] == "true";
} 
$result = verify_app_store_in_app($receipt, $sandbox);

echo $result;

function verify_app_store_in_app($receipt, $is_sandbox) 
{
	//$sandbox should be TRUE if you want to test against iTunes sandbox servers
	if ($is_sandbox)
		$verify_host = "https://sandbox.itunes.apple.com/verifyReceipt";
	else
		$verify_host = "https://buy.itunes.apple.com/verifyReceipt";

	$json='{"receipt-data" : "'.$receipt.'","password" : "**SHARED SECRET HERE**" }';
	//opening socket to itunes

    $response = \Httpful\Request::post($verify_host)                  // Build a PUT request...
    ->sendsJson()                               // tell it we're sending (Content-Type) JSON...
    ->body($json)             // attach a body/payload...
    ->send();

   return $response;

}
