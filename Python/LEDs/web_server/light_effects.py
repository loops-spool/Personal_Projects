import board
import neopixel
import time
import random
import math

num_of_leds = 350
strip = neopixel.NeoPixel(board.D18, num_of_leds, auto_write = False, pixel_order = 'GRB')
amount_of_colors = 1
mult_color_style = "alternating"
has_mult_block_sizes = False
# This controls the time sleep of animated functions
    # Must be a global to accurately store timing data across changes
sleep_amount = 0.5


############################## STATIC FUNCTIONS ##############################

def off():
    strip.fill((0, 0, 0))
    strip.show()


def color(color_arr, amount_of_colors, mult_color_style, has_mult_block_sizes, block_size_arr):
    color_acc = 0
    i = 0
    # Must be in while loop for dynamic stepping of iterator
    while (i < num_of_leds):
        # Setting block size
        block_size = 1 # For alternating
        if mult_color_style == "block":
            if has_mult_block_sizes:
                block_size = block_size_arr[color_acc]
            else:
                block_size = block_size_arr[0]
        # Putting in each color
        for ii in range(block_size):
            # But only if it's on the strip
            if (i + ii) < num_of_leds:
                strip[i + ii] = color_arr[color_acc]
        # Updating the iterator
        i += block_size
        # Updating the color
        color_acc += 1
        color_acc %= amount_of_colors
        

    strip.show()


############################## ANIMATED FUNCTIONS ##############################

def random_colors(brightness_arr, queue_dict):
    global sleep_amount
    while other_effect_isnt_chosen(queue_dict):
        for i in range (num_of_leds):
            strip[i] = (random.randrange(0, 255) * brightness_arr[0], random.randrange(0, 255) * brightness_arr[0], random.randrange(0, 255) * brightness_arr[0])
        strip.show()

        # Checking if animated speed slider has changed
        if not queue_dict["animated effect speed queue"].empty():
            set_sleep_amount(queue_dict)

        # Prevents stroke-inducing light changes
        if (sleep_amount < 0.07):
            time.sleep(0.07)
        else:
            time.sleep(sleep_amount)


def animated_alternating_colors(color_arr, block_size_arr, queue_dict):
    color_acc = 0 # Color accumulator to animate the effect
    starter_acc = 0
    while other_effect_isnt_chosen(queue_dict):
        check_queues(queue_dict)

        i = 0
        # Must be in while loop for dynamic stepping of iterator
        while (i < num_of_leds):
            # Setting block size
            block_size = 1 # For alternating
            if mult_color_style == "block":
                if has_mult_block_sizes:
                    block_size = block_size_arr[color_acc]
                else:
                    block_size = block_size_arr[0]
            # Putting in each color
            for ii in range(block_size):
                # But only if it's on the strip
                if (i + ii) < num_of_leds:
                    strip[i + ii] = color_arr[color_acc]
            # Updating the iterator
            i += block_size
            # Updating the color
            color_acc += 1
            color_acc %= amount_of_colors

        strip.show()

        # Prevents the change of colors occuring so fast the strip appears one color
        if (sleep_amount < 0.07):
            time.sleep(0.07)
        else:
            time.sleep(sleep_amount)

        # Incrementing the color accumulator to cause the animation effect
        color_acc = 0
        starter_acc += 1
        starter_acc %= amount_of_colors
        color_acc += starter_acc


def twinkle(color_arr, block_size_arr, queue_dict):
    brightness = [0] * num_of_leds
    brightness_direction = [0] * num_of_leds
    # Adjusting current slider position to an appropriate range for twinkle
    global sleep_amount
    twinkle_v = (1 - sleep_amount)/15
    prev_sleep_amount = sleep_amount
    max_brightness = 1
    
    # Initializing brightnesses and brightness direction
    for i in range(num_of_leds):
        brightness[i] = random.uniform(.1, max_brightness)
        brightness_direction[i] = random.random() < 0.5

    while other_effect_isnt_chosen(queue_dict):
        check_queues(queue_dict)

        # Checking if animated speed slider has changed
        current_sleep_amount = sleep_amount
        if not current_sleep_amount == prev_sleep_amount:
            twinkle_v = (1 - current_sleep_amount)/15
            prev_sleep_amount = current_sleep_amount

        # So twinkle isn't so incredibly slow and "pixelated"
        if twinkle_v < 0.008:
            twinkle_v = 0.008
        # Or too fast it diminishes the effect
        if twinkle_v > 0.05:
            twinkle_v = 0.05

        color_acc = 0
        i = 0
        while (i < num_of_leds):
            # Setting block size
            block_size = 1 # For alternating
            if mult_color_style == "block":
                if has_mult_block_sizes:
                    block_size = block_size_arr[color_acc]
                else:
                    block_size = block_size_arr[0]
            # Actually doing the colors
            for ii in range(block_size):
                # If the pixel is on the strip
                if (i + ii) < num_of_leds:
                    # Checking bounds
                    if (brightness[i + ii] + twinkle_v) >= max_brightness:
                        brightness_direction[i + ii] = False
                    if (brightness[i + ii] - twinkle_v) <= 0:
                        brightness_direction[i + ii] = True
                    
                    # Incrementing pixel brightness
                    if brightness_direction[i + ii] == True:
                        brightness[i + ii] += twinkle_v
                    else:
                        brightness[i + ii] -= twinkle_v

                    # Applying brightness and color
                    g = math.ceil(color_arr[color_acc][0] * brightness[i + ii])
                    r = math.ceil(color_arr[color_acc][1] * brightness[i + ii])
                    b = math.ceil(color_arr[color_acc][2] * brightness[i + ii])
                    strip[i + ii] = (g, r, b)
            # Updating the accumulator
            i += block_size
            # Updating the color
            color_acc += 1
            color_acc %= amount_of_colors

        strip.show()


def other_effect_isnt_chosen(queue_dict):
    return (queue_dict["looping effect queue"].empty() and queue_dict["static effect queue"].empty())

def check_queues(queue_dict):
    # Checking for colors added/removed
    global amount_of_colors
    if not queue_dict["amount of colors queue"].empty():
        amount_of_colors = int(queue_dict["amount of colors queue"].get())

    # Checking for the style of multiple colors
    global mult_color_style
    if not queue_dict["mult color style queue"].empty():
        mult_color_style = queue_dict["mult color style queue"].get()

    # Checking if it has multiple block sizes
    global has_mult_block_sizes
    if not queue_dict["has mult block sizes queue"].empty():
        has_mult_block_sizes = queue_dict["has mult block sizes queue"].get()

    # Checking if animated speed has changed
    global sleep_amount
    if not queue_dict["animated effect speed queue"].empty():
            set_sleep_amount(queue_dict)

def set_sleep_amount(queue_dict):
    global sleep_amount
    # 1 - to make slider go from slow to fast
    sleep_amount = 1 - float(queue_dict["animated effect speed queue"].get())/100