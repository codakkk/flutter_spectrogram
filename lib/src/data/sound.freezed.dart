// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sound.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Sound {
  double get xmin => throw _privateConstructorUsedError; // Seconds
  double get xmax => throw _privateConstructorUsedError; // Seconds
  int get numberOfSamples => throw _privateConstructorUsedError; // nx
  double get samplingPeriod =>
      throw _privateConstructorUsedError; // Seconds (my dx)
  double get timeOfFirstSample =>
      throw _privateConstructorUsedError; // Seconds (x1)
  int get ymin => throw _privateConstructorUsedError; // Left or only channel
  int get ymax => throw _privateConstructorUsedError; // right or only channels
  int get numberOfChannels => throw _privateConstructorUsedError; // ny
  List<Float64List> get amplitudes => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SoundCopyWith<Sound> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SoundCopyWith<$Res> {
  factory $SoundCopyWith(Sound value, $Res Function(Sound) then) =
      _$SoundCopyWithImpl<$Res, Sound>;
  @useResult
  $Res call(
      {double xmin,
      double xmax,
      int numberOfSamples,
      double samplingPeriod,
      double timeOfFirstSample,
      int ymin,
      int ymax,
      int numberOfChannels,
      List<Float64List> amplitudes});
}

/// @nodoc
class _$SoundCopyWithImpl<$Res, $Val extends Sound>
    implements $SoundCopyWith<$Res> {
  _$SoundCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? xmin = null,
    Object? xmax = null,
    Object? numberOfSamples = null,
    Object? samplingPeriod = null,
    Object? timeOfFirstSample = null,
    Object? ymin = null,
    Object? ymax = null,
    Object? numberOfChannels = null,
    Object? amplitudes = null,
  }) {
    return _then(_value.copyWith(
      xmin: null == xmin
          ? _value.xmin
          : xmin // ignore: cast_nullable_to_non_nullable
              as double,
      xmax: null == xmax
          ? _value.xmax
          : xmax // ignore: cast_nullable_to_non_nullable
              as double,
      numberOfSamples: null == numberOfSamples
          ? _value.numberOfSamples
          : numberOfSamples // ignore: cast_nullable_to_non_nullable
              as int,
      samplingPeriod: null == samplingPeriod
          ? _value.samplingPeriod
          : samplingPeriod // ignore: cast_nullable_to_non_nullable
              as double,
      timeOfFirstSample: null == timeOfFirstSample
          ? _value.timeOfFirstSample
          : timeOfFirstSample // ignore: cast_nullable_to_non_nullable
              as double,
      ymin: null == ymin
          ? _value.ymin
          : ymin // ignore: cast_nullable_to_non_nullable
              as int,
      ymax: null == ymax
          ? _value.ymax
          : ymax // ignore: cast_nullable_to_non_nullable
              as int,
      numberOfChannels: null == numberOfChannels
          ? _value.numberOfChannels
          : numberOfChannels // ignore: cast_nullable_to_non_nullable
              as int,
      amplitudes: null == amplitudes
          ? _value.amplitudes
          : amplitudes // ignore: cast_nullable_to_non_nullable
              as List<Float64List>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SoundImplCopyWith<$Res> implements $SoundCopyWith<$Res> {
  factory _$$SoundImplCopyWith(
          _$SoundImpl value, $Res Function(_$SoundImpl) then) =
      __$$SoundImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double xmin,
      double xmax,
      int numberOfSamples,
      double samplingPeriod,
      double timeOfFirstSample,
      int ymin,
      int ymax,
      int numberOfChannels,
      List<Float64List> amplitudes});
}

/// @nodoc
class __$$SoundImplCopyWithImpl<$Res>
    extends _$SoundCopyWithImpl<$Res, _$SoundImpl>
    implements _$$SoundImplCopyWith<$Res> {
  __$$SoundImplCopyWithImpl(
      _$SoundImpl _value, $Res Function(_$SoundImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? xmin = null,
    Object? xmax = null,
    Object? numberOfSamples = null,
    Object? samplingPeriod = null,
    Object? timeOfFirstSample = null,
    Object? ymin = null,
    Object? ymax = null,
    Object? numberOfChannels = null,
    Object? amplitudes = null,
  }) {
    return _then(_$SoundImpl(
      xmin: null == xmin
          ? _value.xmin
          : xmin // ignore: cast_nullable_to_non_nullable
              as double,
      xmax: null == xmax
          ? _value.xmax
          : xmax // ignore: cast_nullable_to_non_nullable
              as double,
      numberOfSamples: null == numberOfSamples
          ? _value.numberOfSamples
          : numberOfSamples // ignore: cast_nullable_to_non_nullable
              as int,
      samplingPeriod: null == samplingPeriod
          ? _value.samplingPeriod
          : samplingPeriod // ignore: cast_nullable_to_non_nullable
              as double,
      timeOfFirstSample: null == timeOfFirstSample
          ? _value.timeOfFirstSample
          : timeOfFirstSample // ignore: cast_nullable_to_non_nullable
              as double,
      ymin: null == ymin
          ? _value.ymin
          : ymin // ignore: cast_nullable_to_non_nullable
              as int,
      ymax: null == ymax
          ? _value.ymax
          : ymax // ignore: cast_nullable_to_non_nullable
              as int,
      numberOfChannels: null == numberOfChannels
          ? _value.numberOfChannels
          : numberOfChannels // ignore: cast_nullable_to_non_nullable
              as int,
      amplitudes: null == amplitudes
          ? _value._amplitudes
          : amplitudes // ignore: cast_nullable_to_non_nullable
              as List<Float64List>,
    ));
  }
}

/// @nodoc

class _$SoundImpl implements _Sound {
  const _$SoundImpl(
      {required this.xmin,
      required this.xmax,
      required this.numberOfSamples,
      required this.samplingPeriod,
      required this.timeOfFirstSample,
      this.ymin = 1,
      required this.ymax,
      required this.numberOfChannels,
      required final List<Float64List> amplitudes})
      : _amplitudes = amplitudes;

  @override
  final double xmin;
// Seconds
  @override
  final double xmax;
// Seconds
  @override
  final int numberOfSamples;
// nx
  @override
  final double samplingPeriod;
// Seconds (my dx)
  @override
  final double timeOfFirstSample;
// Seconds (x1)
  @override
  @JsonKey()
  final int ymin;
// Left or only channel
  @override
  final int ymax;
// right or only channels
  @override
  final int numberOfChannels;
// ny
  final List<Float64List> _amplitudes;
// ny
  @override
  List<Float64List> get amplitudes {
    if (_amplitudes is EqualUnmodifiableListView) return _amplitudes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amplitudes);
  }

  @override
  String toString() {
    return 'Sound(xmin: $xmin, xmax: $xmax, numberOfSamples: $numberOfSamples, samplingPeriod: $samplingPeriod, timeOfFirstSample: $timeOfFirstSample, ymin: $ymin, ymax: $ymax, numberOfChannels: $numberOfChannels, amplitudes: $amplitudes)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SoundImpl &&
            (identical(other.xmin, xmin) || other.xmin == xmin) &&
            (identical(other.xmax, xmax) || other.xmax == xmax) &&
            (identical(other.numberOfSamples, numberOfSamples) ||
                other.numberOfSamples == numberOfSamples) &&
            (identical(other.samplingPeriod, samplingPeriod) ||
                other.samplingPeriod == samplingPeriod) &&
            (identical(other.timeOfFirstSample, timeOfFirstSample) ||
                other.timeOfFirstSample == timeOfFirstSample) &&
            (identical(other.ymin, ymin) || other.ymin == ymin) &&
            (identical(other.ymax, ymax) || other.ymax == ymax) &&
            (identical(other.numberOfChannels, numberOfChannels) ||
                other.numberOfChannels == numberOfChannels) &&
            const DeepCollectionEquality()
                .equals(other._amplitudes, _amplitudes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      xmin,
      xmax,
      numberOfSamples,
      samplingPeriod,
      timeOfFirstSample,
      ymin,
      ymax,
      numberOfChannels,
      const DeepCollectionEquality().hash(_amplitudes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SoundImplCopyWith<_$SoundImpl> get copyWith =>
      __$$SoundImplCopyWithImpl<_$SoundImpl>(this, _$identity);
}

abstract class _Sound implements Sound {
  const factory _Sound(
      {required final double xmin,
      required final double xmax,
      required final int numberOfSamples,
      required final double samplingPeriod,
      required final double timeOfFirstSample,
      final int ymin,
      required final int ymax,
      required final int numberOfChannels,
      required final List<Float64List> amplitudes}) = _$SoundImpl;

  @override
  double get xmin;
  @override // Seconds
  double get xmax;
  @override // Seconds
  int get numberOfSamples;
  @override // nx
  double get samplingPeriod;
  @override // Seconds (my dx)
  double get timeOfFirstSample;
  @override // Seconds (x1)
  int get ymin;
  @override // Left or only channel
  int get ymax;
  @override // right or only channels
  int get numberOfChannels;
  @override // ny
  List<Float64List> get amplitudes;
  @override
  @JsonKey(ignore: true)
  _$$SoundImplCopyWith<_$SoundImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
