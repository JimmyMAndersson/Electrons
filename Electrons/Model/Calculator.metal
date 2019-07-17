#include <metal_stdlib>
using namespace metal;
#include <metal_math>

#define ELECTRON_FORCE_DISTANCE 5.0
#define ELECTRON_FORCE_DISTANCE_SQUARED 25.0
#define ELECTRON_CHARGE 10.0

struct ElectronStruct {
  float2 position;
  float2 velocity;
};

struct Info {
  uint capacity;
  float maxX;
  float maxY;
  float radius;
  float maxVelocity;
  float wallDistance;
};

kernel void calculate_differentials(device float2 * differentials [[buffer(0)]],
                                    device ElectronStruct * electrons [[buffer(1)]],
                                    constant Info &info,
                                    uint index [[thread_position_in_grid]])
{
  if (index > info.capacity) { return; }
  
  for (uint i = 0; i < info.capacity; i++) {
    if (i != index) {
      float xComp = electrons[i].position.x - electrons[index].position.x;
      float yComp = electrons[i].position.y - electrons[index].position.y;
      float distanceSquared = xComp * xComp + yComp * yComp;
      if (distanceSquared < ELECTRON_FORCE_DISTANCE_SQUARED) {
        float angle = precise::atan2(yComp, xComp);
        float2 force = float2(ELECTRON_CHARGE * cos(angle) / distanceSquared,
                               ELECTRON_CHARGE * sin(angle) / distanceSquared);
        
        differentials[index] -= force;
      }
    }
  }
  
  if (electrons[index].position.x < (info.wallDistance)) {
    float d = electrons[index].position.x - (info.radius) - 1.0;
    float d2 = d * d;
    differentials[index] += float2((20.0 / d2), 0);
  } else if (electrons[index].position.x > (info.maxX - info.wallDistance)) {
    float d = (info.maxX) - electrons[index].position.x - (info.radius) - 1.0;
    float d2 = d * d;
    differentials[index] += float2((-20.0 / d2), 0);
  }

  if (electrons[index].position.y < (info.wallDistance)) {
    float d = electrons[index].position.y - (info.radius) - 1.0;
    float d2 = d * d;
    differentials[index] += float2(0, (20.0 / d2));
  } else if (electrons[index].position.y > (info.maxY - info.wallDistance)) {
    float d = (info.maxY) - electrons[index].position.y - (info.radius) - 1.0;
    float d2 = d * d;
    differentials[index] += float2(0, (-20.0 / d2));
  }
}

kernel void update_electrons(device float2 * differentials [[buffer(0)]],
                             device ElectronStruct * electrons [[buffer(1)]],
                             constant Info &info,
                             uint index [[thread_position_in_grid]])
{
  electrons[index].velocity += differentials[index];

  float x = electrons[index].velocity.x;
  float y = electrons[index].velocity.y;
  float velocity = sqrt(x * x + y * y);

  if (velocity > (info.maxVelocity)) {
    electrons[index].velocity *= info.maxVelocity / velocity;
  }
  
  electrons[index].position += electrons[index].velocity;
  
  if (electrons[index].position.x - info.radius <= 0) {
    electrons[index].position.x = info.radius + 1.0;
    electrons[index].velocity.x *= -1;
  } else if (electrons[index].position.x + info.radius >= info.maxX) {
    electrons[index].position.x = info.maxX - info.radius - 1.0;
    electrons[index].velocity.x *= -1;
  }
  
  if (electrons[index].position.y - info.radius <= 0) {
    electrons[index].position.y = info.radius + 1.0;
    electrons[index].velocity.y *= -1;
  } else if (electrons[index].position.y + info.radius >= info.maxY) {
    electrons[index].position.y = info.maxY - info.radius - 1.0;
    electrons[index].velocity.y *= -1;
  }
}
