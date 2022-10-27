# cython: profile=False
# cython: embedsignature = True
# cython: language_level = 3
# distutils: language = c++

from libcpp cimport bool

cdef extern from "raymath.h":

    cdef struct Vector2:
        float x
        float y

    cdef struct Vector3:
        float x
        float y
        float z

    cdef struct Vector4:
        float x
        float y
        float z
        float w

    ctypedef Vector4 Quaternion

    cdef struct Matrix:
        float m0
        float m4
        float m8
        float m12
        float m1
        float m5
        float m9
        float m13
        float m2
        float m6
        float m10
        float m14
        float m3
        float m7
        float m11
        float m15

    cdef struct float3:
        float v[3]

    cdef struct float16:
        float v[16]

    float Clamp(float value, float min, float max)

    float Lerp(float start, float end, float amount)

    float Normalize(float value, float start, float end)

    float Remap(float value, float inputStart, float inputEnd, float outputStart, float outputEnd)

    float Wrap(float value, float min, float max)

    int FloatEquals(float x, float y)

    Vector2 Vector2Zero()

    Vector2 Vector2One()

    Vector2 Vector2Add(Vector2 v1, Vector2 v2)

    Vector2 Vector2AddValue(Vector2 v, float add)

    Vector2 Vector2Subtract(Vector2 v1, Vector2 v2)

    Vector2 Vector2SubtractValue(Vector2 v, float sub)

    float Vector2Length(Vector2 v)

    float Vector2LengthSqr(Vector2 v)

    float Vector2DotProduct(Vector2 v1, Vector2 v2)

    float Vector2Distance(Vector2 v1, Vector2 v2)

    float Vector2DistanceSqr(Vector2 v1, Vector2 v2)

    float Vector2Angle(Vector2 v1, Vector2 v2)

    Vector2 Vector2Scale(Vector2 v, float scale)

    Vector2 Vector2Multiply(Vector2 v1, Vector2 v2)

    Vector2 Vector2Negate(Vector2 v)

    Vector2 Vector2Divide(Vector2 v1, Vector2 v2)

    Vector2 Vector2Normalize(Vector2 v)

    Vector2 Vector2Transform(Vector2 v, Matrix mat)

    Vector2 Vector2Lerp(Vector2 v1, Vector2 v2, float amount)

    Vector2 Vector2Reflect(Vector2 v, Vector2 normal)

    Vector2 Vector2Rotate(Vector2 v, float angle)

    Vector2 Vector2MoveTowards(Vector2 v, Vector2 target, float maxDistance)

    Vector2 Vector2Invert(Vector2 v)

    Vector2 Vector2Clamp(Vector2 v, Vector2 min, Vector2 max)

    Vector2 Vector2ClampValue(Vector2 v, float min, float max)

    int Vector2Equals(Vector2 p, Vector2 q)

    Vector3 Vector3Zero()

    Vector3 Vector3One()

    Vector3 Vector3Add(Vector3 v1, Vector3 v2)

    Vector3 Vector3AddValue(Vector3 v, float add)

    Vector3 Vector3Subtract(Vector3 v1, Vector3 v2)

    Vector3 Vector3SubtractValue(Vector3 v, float sub)

    Vector3 Vector3Scale(Vector3 v, float scalar)

    Vector3 Vector3Multiply(Vector3 v1, Vector3 v2)

    Vector3 Vector3CrossProduct(Vector3 v1, Vector3 v2)

    Vector3 Vector3Perpendicular(Vector3 v)

    float Vector3Length(Vector3 v)

    float Vector3LengthSqr(Vector3 v)

    float Vector3DotProduct(Vector3 v1, Vector3 v2)

    float Vector3Distance(Vector3 v1, Vector3 v2)

    float Vector3DistanceSqr(Vector3 v1, Vector3 v2)

    float Vector3Angle(Vector3 v1, Vector3 v2)

    Vector3 Vector3Negate(Vector3 v)

    Vector3 Vector3Divide(Vector3 v1, Vector3 v2)

    Vector3 Vector3Normalize(Vector3 v)

    void Vector3OrthoNormalize(Vector3* v1, Vector3* v2)

    Vector3 Vector3Transform(Vector3 v, Matrix mat)

    Vector3 Vector3RotateByQuaternion(Vector3 v, Quaternion q)

    Vector3 Vector3RotateByAxisAngle(Vector3 v, Vector3 axis, float angle)

    Vector3 Vector3Lerp(Vector3 v1, Vector3 v2, float amount)

    Vector3 Vector3Reflect(Vector3 v, Vector3 normal)

    Vector3 Vector3Min(Vector3 v1, Vector3 v2)

    Vector3 Vector3Max(Vector3 v1, Vector3 v2)

    Vector3 Vector3Barycenter(Vector3 p, Vector3 a, Vector3 b, Vector3 c)

    Vector3 Vector3Unproject(Vector3 source, Matrix projection, Matrix view)

    float3 Vector3ToFloatV(Vector3 v)

    Vector3 Vector3Invert(Vector3 v)

    Vector3 Vector3Clamp(Vector3 v, Vector3 min, Vector3 max)

    Vector3 Vector3ClampValue(Vector3 v, float min, float max)

    int Vector3Equals(Vector3 p, Vector3 q)

    Vector3 Vector3Refract(Vector3 v, Vector3 n, float r)

    float MatrixDeterminant(Matrix mat)

    float MatrixTrace(Matrix mat)

    Matrix MatrixTranspose(Matrix mat)

    Matrix MatrixInvert(Matrix mat)

    Matrix MatrixIdentity()

    Matrix MatrixAdd(Matrix left, Matrix right)

    Matrix MatrixSubtract(Matrix left, Matrix right)

    Matrix MatrixMultiply(Matrix left, Matrix right)

    Matrix MatrixTranslate(float x, float y, float z)

    Matrix MatrixRotate(Vector3 axis, float angle)

    Matrix MatrixRotateX(float angle)

    Matrix MatrixRotateY(float angle)

    Matrix MatrixRotateZ(float angle)

    Matrix MatrixRotateXYZ(Vector3 angle)

    Matrix MatrixRotateZYX(Vector3 angle)

    Matrix MatrixScale(float x, float y, float z)

    Matrix MatrixFrustum(double left, double right, double bottom, double top, double near, double far)

    Matrix MatrixPerspective(double fovy, double aspect, double near, double far)

    Matrix MatrixOrtho(double left, double right, double bottom, double top, double near, double far)

    Matrix MatrixLookAt(Vector3 eye, Vector3 target, Vector3 up)

    float16 MatrixToFloatV(Matrix mat)

    Quaternion QuaternionAdd(Quaternion q1, Quaternion q2)

    Quaternion QuaternionAddValue(Quaternion q, float add)

    Quaternion QuaternionSubtract(Quaternion q1, Quaternion q2)

    Quaternion QuaternionSubtractValue(Quaternion q, float sub)

    Quaternion QuaternionIdentity()

    float QuaternionLength(Quaternion q)

    Quaternion QuaternionNormalize(Quaternion q)

    Quaternion QuaternionInvert(Quaternion q)

    Quaternion QuaternionMultiply(Quaternion q1, Quaternion q2)

    Quaternion QuaternionScale(Quaternion q, float mul)

    Quaternion QuaternionDivide(Quaternion q1, Quaternion q2)

    Quaternion QuaternionLerp(Quaternion q1, Quaternion q2, float amount)

    Quaternion QuaternionNlerp(Quaternion q1, Quaternion q2, float amount)

    Quaternion QuaternionSlerp(Quaternion q1, Quaternion q2, float amount)

    Quaternion QuaternionFromVector3ToVector3(Vector3 from_, Vector3 to)

    Quaternion QuaternionFromMatrix(Matrix mat)

    Matrix QuaternionToMatrix(Quaternion q)

    Quaternion QuaternionFromAxisAngle(Vector3 axis, float angle)

    void QuaternionToAxisAngle(Quaternion q, Vector3* outAxis, float* outAngle)

    Quaternion QuaternionFromEuler(float pitch, float yaw, float roll)

    Vector3 QuaternionToEuler(Quaternion q)

    Quaternion QuaternionTransform(Quaternion q, Matrix mat)

    int QuaternionEquals(Quaternion p, Quaternion q)
