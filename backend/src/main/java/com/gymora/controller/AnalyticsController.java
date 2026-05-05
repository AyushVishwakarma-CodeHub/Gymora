package com.gymora.controller;

import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.dto.response.DashboardResponse;
import com.gymora.service.AnalyticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/analytics")
@RequiredArgsConstructor
@Tag(name = "Analytics", description = "Dashboard analytics endpoints")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @GetMapping("/overview")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Get system-wide analytics (Super Admin only)")
    public ResponseEntity<ApiResponse<DashboardResponse>> getSystemOverview() {
        return ResponseEntity.ok(ApiResponse.success(analyticsService.getSystemOverview()));
    }

    @GetMapping("/gyms/{gymId}")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'GYM_ADMIN')")
    @Operation(summary = "Get gym-specific analytics")
    public ResponseEntity<ApiResponse<DashboardResponse>> getGymAnalytics(@PathVariable Long gymId) {
        return ResponseEntity.ok(ApiResponse.success(analyticsService.getGymAnalytics(gymId)));
    }
}
