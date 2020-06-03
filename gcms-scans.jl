#################
### Functions ###
#################

# All the MS data is separated into the mass_values and intensity_values arrays.
# Each of these arrays is one dimensional with the values for each spectrum following
# the last. Each spectrum is stored as centroided values only – and only storing those
# masses (and their intensities) for which an intensity was detected.

# The scan_index and point_count arrays hold the information you need to pull out
# individual mass spectra from the mass_values and intensity_values arrays: scan_index
# will give you the starting index and point_count will give you the number elements to read.

# to check all the available variables in .CDF file use
# ncinfo(filename)

# get some important scan information, probably should just be a TIC
function scaninfo(filename)
    scan_index = ncread(filename, "scan_index")
    scan_acquisition_time = ncread(filename, "scan_acquisition_time")
    mass_range_max = ncread(filename, "mass_range_max")
    point_count = ncread(filename, "point_count")
    return scan_index, scan_acquisition_time, mass_range_max, point_count
end

# load mz,  intensity, and indexes
function MSdata(filename)
    mz = ncread(filename, "mass_values")
    intensity = ncread(filename, "intensity_values")
    scan_index = ncread(filename, "scan_index")
    point_count = ncread(filename, "point_count")
    scan_acquisition_time = ncread(filename, "scan_acquisition_time")
    mass_range_max = ncread(filename, "mass_range_max")
    data = Array{Float32,2}(undef, length(mz), 2) # full data set in Array
    data[:,1] = mz
    data[:,2] = intensity
    return data
end

#  get TIC chromatogram from MS data
function getTIC(data,scan_index,scan_acquisition_time,point_count)
    TIC = Array{Float32,2}(undef, length(scan_index), 2) # full data set in Array
    for i = 1:length(scan_index)
        msscan = data[scan_index[i]+1:scan_index[i]+point_count[i],:]
        total_intensity = sum(msscan[:,2])
        TIC[i,1] = scan_acquisition_time[i]
        TIC[i,2] = sum(msscan[:,2])
    end
    return TIC
end

function plotFID(filename)
    ordinate = ncread(filename, "ordinate_values")
    raw = ncread(filename, "raw_data_retention")
    raw_min = raw/60
    plot(raw_min, ordinate,
        size = (1500,600),
        left_margin = 150px,
        right_margin = 50px,
        bottom_margin = 70px,
        label=splitext(filename)[1],
        legendfontsize = 20,
        xlabel="Minutes",
        xguidefontsize=20,
        ylabel="Intensity",
        yguidefontsize=20,
        xlims = (2,8),
        xticks = 0:0.5:8,
        xtickfont = font(20, "Courier"),
        ytickfont = font(20, "Courier"))

    cd("/home/marneyl/Downloads/200221_OchemDistillation_CDF.AIA/images/")
    imagename = splitext(filename)[1]*".png"
    png(imagename)
end
