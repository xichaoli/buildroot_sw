choice
	prompt "Target Architecture Variant"
	depends on BR2_sw_64
	default BR2_variant_sw_64 if BR2_sw_64
	help
	  Specific CPU variant to use

config BR2_variant_sw_64
	bool "sw_64"

endchoice

config BR2_ARCH
	string
	default "sw_64"

config BR2_ENDIAN
	string
	default "LITTLE"

config BR2_ARCH_HAS_ATOMICS
	string
	default y 

config BR2_GCC_TARGET_TUNE
	string
	default "sw_64"

config BR2_GCC_TARGET_ARCH
	string
	default "sw_64"

config BR2_READELF_ARCH_NAME
	string
	default "Sw_64"
