# Bundled English wake-word model

This is the int8 subset of
`sherpa-onnx-kws-zipformer-gigaspeech-3.3M-2024-01-01`:

- Source: https://github.com/k2-fsa/sherpa-onnx/releases/tag/kws-models
- Training data: GigaSpeech XL
- Modeling unit: SentencePiece BPE
- License: Apache-2.0

The package includes the encoder, decoder, joiner, `tokens.txt`, and
`bpe.model`. `SherpaOnnxWakeWordDetector.create` extracts these assets to a
versioned runtime cache and converts plain English phrases to sherpa keyword
tokens automatically.
