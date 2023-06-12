from datetime import datetime
from s3_transformer import S3TransformationApp


def test_results_filename_path_creator():
    mock_access_key_id = "MOCK_ACCESS_KEY"
    mock_secret_key = "MOCK_SECRET_KEY"
    mock_s3_bucket_name = "MOCK_BUCKET_NAME"

    instance = S3TransformationApp(mock_access_key_id, mock_secret_key, mock_s3_bucket_name)

    date = datetime.now().strftime("%Y-%m-%d")

    folder = "test_folder"
    result = instance.results_filename_path_creator(folder)

    expected_file_path = f"test_folder/{date}_results.json"

    assert result == expected_file_path