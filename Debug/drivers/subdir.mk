################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../drivers/debug_printf.c \
../drivers/gpio.c \
../drivers/timer32.c 

OBJS += \
./drivers/debug_printf.o \
./drivers/gpio.o \
./drivers/timer32.o 

C_DEPS += \
./drivers/debug_printf.d \
./drivers/gpio.d \
./drivers/timer32.d 


# Each subdirectory must supply rules for building sources it contributes
drivers/%.o: ../drivers/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU C Compiler'
	arm-none-eabi-gcc -D__REDLIB__ -DDEBUG -D__CODE_RED -DCORE_M0 -D__USE_CMSIS=CMSIS_CORE_LPC11xx -D__LPC11XX__ -I"C:\Users\Conrad\Documents\LPCXpresso_6.1.2_177\workspace\DDL_Lab6\inc" -I"C:\Users\Conrad\Documents\LPCXpresso_6.1.2_177\workspace\CMSIS_CORE_LPC11xx\inc" -I"C:\Users\Conrad\Documents\LPCXpresso_6.1.2_177\workspace\DDL_Lab6\drivers" -I"C:\Users\Conrad\Documents\LPCXpresso_6.1.2_177\workspace\lib_small_printf_m0\inc" -O0 -g3 -Wall -c -fmessage-length=0 -fno-builtin -ffunction-sections -fdata-sections -mcpu=cortex-m0 -mthumb -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


