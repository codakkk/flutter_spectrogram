// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spectrogram.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Spectrogram {
  double get tmin => throw _privateConstructorUsedError; // tmin or xmin
  double get tmax => throw _privateConstructorUsedError; // tmax or xmax
  int get numberOfTimeSlices => throw _privateConstructorUsedError; //nx or nt
  double get timeBetweenTimeSlices =>
      throw _privateConstructorUsedError; // dt or dx
  double get centerOfFirstTimeSlice =>
      throw _privateConstructorUsedError; // t1 or x1
  double get minFrequencyHz =>
      throw _privateConstructorUsedError; // ymin or fmin
  double get maxFrequencyHz =>
      throw _privateConstructorUsedError; // ymax or fmax
  int get numberOfFreqs => throw _privateConstructorUsedError; // nf or ny
  double get frequencyStepHz => throw _privateConstructorUsedError; // df or dy
  double get centerOfFirstFrequencyBandHz =>
      throw _privateConstructorUsedError; // y1 or f1
  List<List<double>> get powerSpectrumDensity =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SpectrogramCopyWith<Spectrogram> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpectrogramCopyWith<$Res> {
  factory $SpectrogramCopyWith(
          Spectrogram value, $Res Function(Spectrogram) then) =
      _$SpectrogramCopyWithImpl<$Res, Spectrogram>;
  @useResult
  $Res call(
      {double tmin,
      double tmax,
      int numberOfTimeSlices,
      double timeBetweenTimeSlices,
      double centerOfFirstTimeSlice,
      double minFrequencyHz,
      double maxFrequencyHz,
      int numberOfFreqs,
      double frequencyStepHz,
      double centerOfFirstFrequencyBandHz,
      List<List<double>> powerSpectrumDensity});
}

/// @nodoc
class _$SpectrogramCopyWithImpl<$Res, $Val extends Spectrogram>
    implements $SpectrogramCopyWith<$Res> {
  _$SpectrogramCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmin = null,
    Object? tmax = null,
    Object? numberOfTimeSlices = null,
    Object? timeBetweenTimeSlices = null,
    Object? centerOfFirstTimeSlice = null,
    Object? minFrequencyHz = null,
    Object? maxFrequencyHz = null,
    Object? numberOfFreqs = null,
    Object? frequencyStepHz = null,
    Object? centerOfFirstFrequencyBandHz = null,
    Object? powerSpectrumDensity = null,
  }) {
    return _then(_value.copyWith(
      tmin: null == tmin
          ? _value.tmin
          : tmin // ignore: cast_nullable_to_non_nullable
              as double,
      tmax: null == tmax
          ? _value.tmax
          : tmax // ignore: cast_nullable_to_non_nullable
              as double,
      numberOfTimeSlices: null == numberOfTimeSlices
          ? _value.numberOfTimeSlices
          : numberOfTimeSlices // ignore: cast_nullable_to_non_nullable
              as int,
      timeBetweenTimeSlices: null == timeBetweenTimeSlices
          ? _value.timeBetweenTimeSlices
          : timeBetweenTimeSlices // ignore: cast_nullable_to_non_nullable
              as double,
      centerOfFirstTimeSlice: null == centerOfFirstTimeSlice
          ? _value.centerOfFirstTimeSlice
          : centerOfFirstTimeSlice // ignore: cast_nullable_to_non_nullable
              as double,
      minFrequencyHz: null == minFrequencyHz
          ? _value.minFrequencyHz
          : minFrequencyHz // ignore: cast_nullable_to_non_nullable
              as double,
      maxFrequencyHz: null == maxFrequencyHz
          ? _value.maxFrequencyHz
          : maxFrequencyHz // ignore: cast_nullable_to_non_nullable
              as double,
      numberOfFreqs: null == numberOfFreqs
          ? _value.numberOfFreqs
          : numberOfFreqs // ignore: cast_nullable_to_non_nullable
              as int,
      frequencyStepHz: null == frequencyStepHz
          ? _value.frequencyStepHz
          : frequencyStepHz // ignore: cast_nullable_to_non_nullable
              as double,
      centerOfFirstFrequencyBandHz: null == centerOfFirstFrequencyBandHz
          ? _value.centerOfFirstFrequencyBandHz
          : centerOfFirstFrequencyBandHz // ignore: cast_nullable_to_non_nullable
              as double,
      powerSpectrumDensity: null == powerSpectrumDensity
          ? _value.powerSpectrumDensity
          : powerSpectrumDensity // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpectrogramImplCopyWith<$Res>
    implements $SpectrogramCopyWith<$Res> {
  factory _$$SpectrogramImplCopyWith(
          _$SpectrogramImpl value, $Res Function(_$SpectrogramImpl) then) =
      __$$SpectrogramImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double tmin,
      double tmax,
      int numberOfTimeSlices,
      double timeBetweenTimeSlices,
      double centerOfFirstTimeSlice,
      double minFrequencyHz,
      double maxFrequencyHz,
      int numberOfFreqs,
      double frequencyStepHz,
      double centerOfFirstFrequencyBandHz,
      List<List<double>> powerSpectrumDensity});
}

/// @nodoc
class __$$SpectrogramImplCopyWithImpl<$Res>
    extends _$SpectrogramCopyWithImpl<$Res, _$SpectrogramImpl>
    implements _$$SpectrogramImplCopyWith<$Res> {
  __$$SpectrogramImplCopyWithImpl(
      _$SpectrogramImpl _value, $Res Function(_$SpectrogramImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tmin = null,
    Object? tmax = null,
    Object? numberOfTimeSlices = null,
    Object? timeBetweenTimeSlices = null,
    Object? centerOfFirstTimeSlice = null,
    Object? minFrequencyHz = null,
    Object? maxFrequencyHz = null,
    Object? numberOfFreqs = null,
    Object? frequencyStepHz = null,
    Object? centerOfFirstFrequencyBandHz = null,
    Object? powerSpectrumDensity = null,
  }) {
    return _then(_$SpectrogramImpl(
      tmin: null == tmin
          ? _value.tmin
          : tmin // ignore: cast_nullable_to_non_nullable
              as double,
      tmax: null == tmax
          ? _value.tmax
          : tmax // ignore: cast_nullable_to_non_nullable
              as double,
      numberOfTimeSlices: null == numberOfTimeSlices
          ? _value.numberOfTimeSlices
          : numberOfTimeSlices // ignore: cast_nullable_to_non_nullable
              as int,
      timeBetweenTimeSlices: null == timeBetweenTimeSlices
          ? _value.timeBetweenTimeSlices
          : timeBetweenTimeSlices // ignore: cast_nullable_to_non_nullable
              as double,
      centerOfFirstTimeSlice: null == centerOfFirstTimeSlice
          ? _value.centerOfFirstTimeSlice
          : centerOfFirstTimeSlice // ignore: cast_nullable_to_non_nullable
              as double,
      minFrequencyHz: null == minFrequencyHz
          ? _value.minFrequencyHz
          : minFrequencyHz // ignore: cast_nullable_to_non_nullable
              as double,
      maxFrequencyHz: null == maxFrequencyHz
          ? _value.maxFrequencyHz
          : maxFrequencyHz // ignore: cast_nullable_to_non_nullable
              as double,
      numberOfFreqs: null == numberOfFreqs
          ? _value.numberOfFreqs
          : numberOfFreqs // ignore: cast_nullable_to_non_nullable
              as int,
      frequencyStepHz: null == frequencyStepHz
          ? _value.frequencyStepHz
          : frequencyStepHz // ignore: cast_nullable_to_non_nullable
              as double,
      centerOfFirstFrequencyBandHz: null == centerOfFirstFrequencyBandHz
          ? _value.centerOfFirstFrequencyBandHz
          : centerOfFirstFrequencyBandHz // ignore: cast_nullable_to_non_nullable
              as double,
      powerSpectrumDensity: null == powerSpectrumDensity
          ? _value._powerSpectrumDensity
          : powerSpectrumDensity // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
    ));
  }
}

/// @nodoc

class _$SpectrogramImpl extends _Spectrogram {
  const _$SpectrogramImpl(
      {required this.tmin,
      required this.tmax,
      required this.numberOfTimeSlices,
      required this.timeBetweenTimeSlices,
      required this.centerOfFirstTimeSlice,
      required this.minFrequencyHz,
      required this.maxFrequencyHz,
      required this.numberOfFreqs,
      required this.frequencyStepHz,
      required this.centerOfFirstFrequencyBandHz,
      required final List<List<double>> powerSpectrumDensity})
      : _powerSpectrumDensity = powerSpectrumDensity,
        super._();

  @override
  final double tmin;
// tmin or xmin
  @override
  final double tmax;
// tmax or xmax
  @override
  final int numberOfTimeSlices;
//nx or nt
  @override
  final double timeBetweenTimeSlices;
// dt or dx
  @override
  final double centerOfFirstTimeSlice;
// t1 or x1
  @override
  final double minFrequencyHz;
// ymin or fmin
  @override
  final double maxFrequencyHz;
// ymax or fmax
  @override
  final int numberOfFreqs;
// nf or ny
  @override
  final double frequencyStepHz;
// df or dy
  @override
  final double centerOfFirstFrequencyBandHz;
// y1 or f1
  final List<List<double>> _powerSpectrumDensity;
// y1 or f1
  @override
  List<List<double>> get powerSpectrumDensity {
    if (_powerSpectrumDensity is EqualUnmodifiableListView)
      return _powerSpectrumDensity;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_powerSpectrumDensity);
  }

  @override
  String toString() {
    return 'Spectrogram(tmin: $tmin, tmax: $tmax, numberOfTimeSlices: $numberOfTimeSlices, timeBetweenTimeSlices: $timeBetweenTimeSlices, centerOfFirstTimeSlice: $centerOfFirstTimeSlice, minFrequencyHz: $minFrequencyHz, maxFrequencyHz: $maxFrequencyHz, numberOfFreqs: $numberOfFreqs, frequencyStepHz: $frequencyStepHz, centerOfFirstFrequencyBandHz: $centerOfFirstFrequencyBandHz, powerSpectrumDensity: $powerSpectrumDensity)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpectrogramImpl &&
            (identical(other.tmin, tmin) || other.tmin == tmin) &&
            (identical(other.tmax, tmax) || other.tmax == tmax) &&
            (identical(other.numberOfTimeSlices, numberOfTimeSlices) ||
                other.numberOfTimeSlices == numberOfTimeSlices) &&
            (identical(other.timeBetweenTimeSlices, timeBetweenTimeSlices) ||
                other.timeBetweenTimeSlices == timeBetweenTimeSlices) &&
            (identical(other.centerOfFirstTimeSlice, centerOfFirstTimeSlice) ||
                other.centerOfFirstTimeSlice == centerOfFirstTimeSlice) &&
            (identical(other.minFrequencyHz, minFrequencyHz) ||
                other.minFrequencyHz == minFrequencyHz) &&
            (identical(other.maxFrequencyHz, maxFrequencyHz) ||
                other.maxFrequencyHz == maxFrequencyHz) &&
            (identical(other.numberOfFreqs, numberOfFreqs) ||
                other.numberOfFreqs == numberOfFreqs) &&
            (identical(other.frequencyStepHz, frequencyStepHz) ||
                other.frequencyStepHz == frequencyStepHz) &&
            (identical(other.centerOfFirstFrequencyBandHz,
                    centerOfFirstFrequencyBandHz) ||
                other.centerOfFirstFrequencyBandHz ==
                    centerOfFirstFrequencyBandHz) &&
            const DeepCollectionEquality()
                .equals(other._powerSpectrumDensity, _powerSpectrumDensity));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      tmin,
      tmax,
      numberOfTimeSlices,
      timeBetweenTimeSlices,
      centerOfFirstTimeSlice,
      minFrequencyHz,
      maxFrequencyHz,
      numberOfFreqs,
      frequencyStepHz,
      centerOfFirstFrequencyBandHz,
      const DeepCollectionEquality().hash(_powerSpectrumDensity));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpectrogramImplCopyWith<_$SpectrogramImpl> get copyWith =>
      __$$SpectrogramImplCopyWithImpl<_$SpectrogramImpl>(this, _$identity);
}

abstract class _Spectrogram extends Spectrogram {
  const factory _Spectrogram(
          {required final double tmin,
          required final double tmax,
          required final int numberOfTimeSlices,
          required final double timeBetweenTimeSlices,
          required final double centerOfFirstTimeSlice,
          required final double minFrequencyHz,
          required final double maxFrequencyHz,
          required final int numberOfFreqs,
          required final double frequencyStepHz,
          required final double centerOfFirstFrequencyBandHz,
          required final List<List<double>> powerSpectrumDensity}) =
      _$SpectrogramImpl;
  const _Spectrogram._() : super._();

  @override
  double get tmin;
  @override // tmin or xmin
  double get tmax;
  @override // tmax or xmax
  int get numberOfTimeSlices;
  @override //nx or nt
  double get timeBetweenTimeSlices;
  @override // dt or dx
  double get centerOfFirstTimeSlice;
  @override // t1 or x1
  double get minFrequencyHz;
  @override // ymin or fmin
  double get maxFrequencyHz;
  @override // ymax or fmax
  int get numberOfFreqs;
  @override // nf or ny
  double get frequencyStepHz;
  @override // df or dy
  double get centerOfFirstFrequencyBandHz;
  @override // y1 or f1
  List<List<double>> get powerSpectrumDensity;
  @override
  @JsonKey(ignore: true)
  _$$SpectrogramImplCopyWith<_$SpectrogramImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
