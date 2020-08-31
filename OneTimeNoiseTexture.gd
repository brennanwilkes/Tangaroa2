extends Sprite



export var noise_size = Vector2(250.0,250.0);
export var noise_scale = Vector2(1.0,1.0);
export var noise_shift = Vector3(0.0,0.0,0.0);

export var lacunarity = 2.0;
export var octaves = 8;
export var period = 64.0;
export var persistence = 0.5;
export var seed_num = 0;

var height_data = [];

var img;
var noise;

func generate_texture():
	img.create(noise_size.x,noise_size.y,false,Image.FORMAT_RGB8);
	img.lock();
	var colour;
	for x in range(noise_size.x):
		for y in range(noise_size.y):
			colour = height_data[x][y];
			img.set_pixel(x,y,Color(colour,colour,colour,1));
	img.unlock();
	var imageTexture = ImageTexture.new();
	imageTexture.create_from_image(img);
	print(imageTexture)
	return imageTexture;

func update_noise_settings():
	noise.seed = seed_num;
	noise.octaves = octaves;
	noise.period = period;
	noise.persistence = persistence;
	noise.lacunarity = lacunarity;

func update_texture():
	self.texture = generate_texture();

func update_heightmap_data():
	var colour
	for x in range(noise_size.x):
		height_data.append([]);
		for y in range(noise_size.y):
			colour = noise.get_noise_3d(x*noise_scale.x + noise_shift.x,y*noise_scale.y + noise_shift.y , noise_shift.z);
			colour += 1;
			colour /= 2;
			
			height_data[x].append(colour);

func _ready():
	img = Image.new();
	

	noise = OpenSimplexNoise.new();
	update_noise_settings();
	
	update_heightmap_data();
	#update_texture();
	

func _process(delta):
	pass
	#noise_shift.z += 10.0 * delta;
	#print(delta)
	#update_heightmap_data();

