<?php

// deviceToken，没有空格
$deviceToken = 'd71ea28044e942c92678ab9ae010f3974c76e21c2c90d0b7b9591047e45941ce';

// pem文件密码
$passphrase = 'demo';

// 消息内容
$message = '这是一条测试消息';

////////////////////////////////////////////////////////////////////////////////

$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'local_cert', 'demo_aps_ck.pem');
stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);

// 开启一个到APNS服务器的连接
$fp = stream_socket_client(
	'ssl://gateway.sandbox.push.apple.com:2195', $err,
	$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

if (!$fp)
	exit("Failed to connect: $err $errstr" . PHP_EOL);

echo 'Connected to APNS' . PHP_EOL;

// 消息主体
$body['aps'] = array(
	'alert' => $message,
	'sound' => 'default',
	'badge' => 2,
	'content-available' => 1 
	);

$payload = json_encode($body);


// Build the binary notification
$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

// 发送到APNS服务器
$result = fwrite($fp, $msg, strlen($msg));


if (!$result)
	echo 'Message not delivered' . PHP_EOL;
else
	echo 'Message successfully delivered' . PHP_EOL;

// 关闭到APNS服务器的连接
fclose($fp);
    
?>
