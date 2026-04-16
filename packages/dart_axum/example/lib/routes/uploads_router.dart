import 'package:dart_axum/dart_axum.dart';

import '../models/user_models.dart';

final AxumSchemaComponent _uploadSummaryComponent = AxumSchemaComponent.object(
  name: 'UploadSummary',
  description: 'Summary response for the multipart upload example.',
  properties: <String, AxumSchema>{
    'owner': AxumSchema.string(description: 'Owner field from the multipart body.'),
    'notes': AxumSchema.string(description: 'Optional notes field.'),
    'filename': AxumSchema.string(description: 'Original uploaded filename.'),
    'contentType': AxumSchema.string(description: 'Detected content type for the uploaded file.'),
    'sizeBytes': AxumSchema.integer(description: 'Uploaded file size in bytes.'),
  },
  required: const <String>{'owner', 'filename', 'sizeBytes'},
);

AxumRouter buildUploadsRouter() {
  return AxumRouter(
    build: (router) {
      router.post(
        '/',
        handler: (context) {
          final form = context.multipartFormData();
          final owner = form.requireField('owner').trim();
          if (owner.isEmpty) {
            throw AxumHttpException(400, message: 'owner must not be empty');
          }

          final notes = form.field('notes');
          final files = form.files('file');
          final file = files.isEmpty ? null : files.first;
          if (file == null) {
            throw AxumHttpException(400, message: 'file must be provided');
          }

          return AxumResponse.json(<String, Object?>{
            'owner': owner,
            'notes': notes,
            'filename': file.filename,
            'contentType': file.contentType,
            'sizeBytes': file.bytes.length,
          });
        },
        docs: AxumRouteDocs(
          summary: 'Upload multipart form data',
          description: 'Accepts an owner field, notes field, and one uploaded file.',
          tags: const <String>['uploads'],
          requestBody: const AxumRequestBodyDocs(
            description: 'Multipart upload body.',
            contentType: 'multipart/form-data',
            schema: AxumSchema.object(
              properties: <String, AxumSchema>{
                'owner': AxumSchema.string(),
                'notes': AxumSchema.string(),
                'file': AxumSchema.string(format: 'binary'),
              },
              required: <String>{'owner', 'file'},
            ),
          ),
          responses: <int, AxumResponseDocs>{
            200: AxumResponseDocs(
              description: 'Upload summary.',
              schema: _uploadSummaryComponent.reference,
              components: <AxumSchemaComponent>[_uploadSummaryComponent],
            ),
            400: AxumResponseDocs(
              description: 'Upload validation error.',
              schema: apiErrorComponent.reference,
              components: <AxumSchemaComponent>[apiErrorComponent],
            ),
          },
        ),
      );
    },
  );
}
