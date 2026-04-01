<?php

$target_dir = "uploads/";
$image_url_base = "http://localhost/ip1/uploads/"; 

if (!file_exists($target_dir)) {
    mkdir($target_dir, 0777, true);
}

if(isset($_FILES["file"])) {
    $imageFileType = strtolower(pathinfo($_FILES["file"]["name"],PATHINFO_EXTENSION));
    $new_file_name = uniqid() . "." . $imageFileType;
    $target_file = $target_dir . $new_file_name;

    if (move_uploaded_file($_FILES["file"]["tmp_name"], $target_file)) {
        echo $image_url_base . $new_file_name;
    } else {
        echo "Error uploading file.";
    }
} else {
    echo "No file was sent.";
}

?>