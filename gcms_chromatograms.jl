# spectra for peak
function peakSpectra(filename,peaktime) # peaktime in minutes
    scan_index, scan_acquisition_time, mass_range_max, point_count = scaninfo(filename)
    data = MSdata(filename)
    peaktime = peaktime[1]*60 # scan_aquisition_time is in seconds
    irt = searchsorted(scan_acquisition_time,peaktime).stop
    spectra = data[scan_index[irt]+1:scan_index[irt]+point_count[irt],:]
    return spectra
end

function gcms_eic(filename,mzs)
    scan_index, scan_acquisition_time, mass_range_max, point_count = scaninfo(filename)
    data = MSdata(filename)
    data_eic = Array{Float32,2}(undef,size(scan_index)[1],2)
    scan_acquisition_time_min = scan_acquisition_time/60
    data_eic[:,1] = scan_acquisition_time_min
    data_eic[:,2] = zeros(size(scan_index)[1])
    for i = 1:length(scan_index)
        msscan = data[scan_index[i]+1:scan_index[i]+point_count[i],:]
        msscan_eic = zeros(Float32,size(mzs)[1],2)
        msscan_eic[:,1] = mzs
        for j = 1:size(msscan)[1]
            msscan[j,1] = round(msscan[j,1])
            for k = 1:length(mzs)
                if msscan[j,1] == mzs[k]
                    msscan_eic[k,2] = msscan[j,2]
                end
            end
        end
        data_eic[i,2] = sum(msscan_eic[:,2])
    end
    return data_eic
end

function peakfind_max(chromatogram,rtrange)
    left = searchsorted(chromatogram[:,1],rtrange[1]).stop
    right = searchsorted(chromatogram[:,1],rtrange[2]).stop
    window = chromatogram[left:right,:]
    windowsorted = window[sortperm(window[:,2]), :]
    peakmax = windowsorted[size(windowsorted)[1],:]
    return peakmax
end

function peakfind_derivative(chromatogram)
    derivative_chromatogram = Array{Float32,2}(undef,size(scan_index)[1],2)
    scan_acquisition_time_min = chromatogram[:,1]
    derivative_chromatogram[:,1] = scan_acquisition_time_min
    derivative_chromatogram[:,2] = zeros(size(scan_index)[1])
    i = size(chromatogram)[1]
    while i > 1
        derivative_chromatogram[size(chromatogram)[1],2] = chromatogram[size(chromatogram)[1],2] - chromatogram[size(chromatogram)[1]-1,2]
        chromatogram = chromatogram[1:size(chromatogram)[1]-1,:]
        i = i - 1
    end
    return derivative_chromatogram
end
